module Engine {

    class PredictionEngine {
        // =========================
        // PROFILE
        // =========================
        var weight;
        // =========================
        // CONFIG
        // =========================

        var glycogenCapacity;

        // =========================
        // INIT
        // =========================

        function initialize(profile) {
            weight = profile.weight;
            // Estimated glycogen storage
            glycogenCapacity = 400;
        }

        // =========================
        // MAIN UPDATE
        // =========================

        function update(state) {
            var ri = state.relativeIntensity;
            var elapsed = state.elapsedTime;
            var hydrationDeficit =
                state.hydrationDeficitMl;
            var carbsDeficit =
                state.carbsDeficit;

            // =================================
            // GLYCOGEN
            // =================================

            var glycogenRemaining =
                calculateRemainingGlycogen(
                    carbsDeficit
                );

            // =================================
            // FATIGUE
            // =================================

            var fatigue =
                calculateFatigue(
                    ri,
                    elapsed,
                    hydrationDeficit
                );

            state.fatiguePercent =
                Utils.FormatUtils
                    .formatPercent(
                        fatigue
                    );

            // =================================
            // BONK RISK
            // =================================

            var bonkRisk =
                calculateBonkRisk(
                    glycogenRemaining,
                    hydrationDeficit,
                    ri
                );

            state.bonkRisk = bonkRisk;

            // =================================
            // BONK TIME
            // =================================

            var bonkTime =
                estimateBonkTime(
                    glycogenRemaining,
                    ri
                );

            state.bonkTimeLabel =
                Utils.FormatUtils
                    .formatCountdown(
                        bonkTime
                    );

            // =================================
            // STATUS
            // =================================

            state.statusLabel =
                calculateStatus(
                    fatigue,
                    bonkRisk
                );
        }

        // =====================================
        // GLYCOGEN MODEL
        // =====================================

        function calculateRemainingGlycogen(
            carbsDeficit
        ) {

            var remaining =
                glycogenCapacity
                - carbsDeficit;

            if (remaining > glycogenCapacity) {

                remaining =
                    glycogenCapacity;
            }

            if (remaining < 0) {

                remaining = 0;
            }

            return remaining;
        }

        // =========================
        // FATIGUE MODEL
        // =========================
        function calculateFatigue(
            relativeIntensity,
            elapsed,
            hydration
        ) {

            var fatigue = 0.0;

            var hours = elapsed / 3600000.0;

            // Duración
            fatigue += hours * 15;

            // Intensidad
            fatigue += relativeIntensity * 30;

            // Hidratación
            var dehydrationPercent =
                hydration / (weight * 10.0);

            fatigue += dehydrationPercent * 15;

            if (fatigue > 100) {
                fatigue = 100;
            }

            return fatigue;
        }

        // =========================
        // BONK RISK
        // =========================

        function calculateBonkRisk(
            glycogenRemaining,
            hydrationDeficit,
            relativeIntensity
        ) {

            var risk = 0;

            // =============================
            // GLYCOGEN
            // =============================

            if (glycogenRemaining < 150) {
                risk += 15;
            }

            if (glycogenRemaining < 80) {
                risk += 25;
            }

            if (glycogenRemaining < 40) {
                risk += 40;
            }

            // =============================
            // HYDRATION
            // =============================

            if (hydrationDeficit > 1000) {
                risk += 10;
            }

            if (hydrationDeficit > 1800) {
                risk += 20;
            }

            // =============================
            // INTENSITY
            // =============================

            if (relativeIntensity > 0.80) {
                risk += 15;
            }

            if (relativeIntensity > 0.90) {
                risk += 20;
            }

            // Clamp
            if (risk > 100) {
                risk = 100;
            }

            return risk;
        }

        // =====================================
        // BONK TIME ESTIMATION
        // =====================================

        function estimateBonkTime(
            glycogenRemaining,
            relativeIntensity
        ) {

            var burnRate =
                20 +
                (relativeIntensity * 80);

            if (burnRate <= 0) {
                return 999;
            }

            // Minutes remaining
            return
                (
                    glycogenRemaining
                    / burnRate
                ) * 60;
        }

        // =========================
        // STATUS LABEL
        // =========================

        function calculateStatus(
            fatigue,
            bonkRisk
        ) {

            if (bonkRisk > 80) {
                return "CRITICAL";
            }

            if (fatigue > 75) {
                return "FATIGUED";
            }

            if (fatigue > 50) {
                return "MODERATE";
            }

            return "STABLE";
        }
    }
}