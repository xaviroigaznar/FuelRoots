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
            glycogenCapacity = 400;
        }

        // =========================
        // MAIN UPDATE
        // =========================

        function update(state) {

            var ri = state.relativeIntensity;
            var elapsed = state.elapsedTime;
            var hydration = state.hydrationDeficitMl;
            var glycogen = state.glycogenRemaining;

            // Fatigue model
            state.fatiguePercent = calculateFatigue(ri, elapsed, hydration);

            // Bonk risk
            state.bonkRisk =
                calculateBonkRisk(
                    glycogen,
                    hydration,
                    ri
                );

            // Status label
            state.statusLabel =
                calculateStatus(
                    state.fatiguePercent,
                    state.bonkRisk
                );
        }

        // =========================
        // FATIGUE MODEL
        // =========================

        function calculateFatigue(
            relativeIntensity,
            elapsed,
            hydration
        ) {

            var fatigue = 0;

            // Duration contribution
            fatigue += elapsed / 1800.0;

            fatigue += relativeIntensity * 25;

            // Hydration contribution
            fatigue += hydration / 250.0;

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
            glycogen,
            hydration,
            ri
        ) {

            var risk = 0;

            // Glycogen contribution
            if (glycogen < 70) {
                risk += 20;
            }

            if (glycogen < 40) {
                risk += 30;
            }

            if (glycogen < 20) {
                risk += 40;
            }

            // Hydration contribution
            if (hydration > 1000) {
                risk += 15;
            }

            if (hydration > 1800) {
                risk += 20;
            }

            // High power contribution
            if (ri > 0.8) {
                risk += 20;
            }

            if (risk > 100) {
                risk = 100;
            }

            return risk;
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