module Engine {

    class PredictionEngine {

        // =========================
        // CONFIG
        // =========================

        var glycogenCapacity;

        // =========================
        // INIT
        // =========================

        function initialize() {
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
            var carbsBurned =
                state.sessionCarbsBurned;
            var carbsIngested =
                state.sessionCarbsIngested;

            // =================================
            // GLYCOGEN
            // =================================

            var glycogenRemaining =
                calculateRemainingGlycogen(
                    carbsBurned,
                    carbsIngested
                );

            state.glycogenRemaining =
                glycogenRemaining;

            state.glycogenPercent =
                Utils.FormatUtils
                    .formatPercent(
                    (glycogenRemaining
                    / glycogenCapacity
                ) * 100);

            // =================================
            // FATIGUE
            // =================================

            var fatigue =
                calculateFatigue(
                    ri,
                    elapsed,
                    hydrationDeficit,
                    glycogenRemaining
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

            state.bonkRisk =
                bonkRisk;

            state.bonkRiskLabel =
                Utils.FormatUtils
                    .formatPercent(
                        bonkRisk
                    );

            // =================================
            // BONK TIME
            // =================================

            var bonkTime =
                estimateBonkTime(
                    glycogenRemaining,
                    ri
                );

            state.bonkTimeLabel =
                bonkTime;

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
            carbsBurned,
            carbsIngested
        ) {

            var remaining =
                glycogenCapacity
                - carbsBurned
                + carbsIngested;

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
            hydrationDeficit,
            glycogenRemaining
        ) {

            var fatigue = 0;

            // =============================
            // DURATION
            // =============================

            fatigue +=
                elapsed / 2400.0;

            // =============================
            // INTENSITY
            // =============================

            fatigue +=
                relativeIntensity * 30;

            // =============================
            // HYDRATION
            // =============================

            fatigue +=
                hydrationDeficit / 300.0;

            // =============================
            // LOW GLYCOGEN
            // =============================

            if (glycogenRemaining < 150) {

                fatigue += 10;
            }

            if (glycogenRemaining < 80) {

                fatigue += 15;
            }

            if (glycogenRemaining < 40) {

                fatigue += 25;
            }

            // Clamp
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