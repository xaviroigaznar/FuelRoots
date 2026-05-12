module Engine {
    using Toybox.Activity;
    using Toybox.Math;
    using Toybox.System;

    class PredictionEngine {

        // =========================
        // CONFIG
        // =========================
        var glycogenCapacity = 400;

        // =========================
        // INIT
        // =========================
        function initialize() {}

        function update(state) {
            state.bonkTimeEstimate = predictBonkTime(state.hydrationDeficit, state.ifValue);
            state.fuelRecommendation = shouldFuelNow(state.hydrationDeficit, state.ifValue);
        }

        // =========================
        // CARB BURN
        // =========================
        function estimateCarbBurnRate(IF) {
            if (IF < 0.60) {
                return 40;
            }

            if (IF < 0.70) {
                return 55;
            }

            if (IF < 0.80) {
                return 70;
            }

            if (IF < 0.90) {
                return 90;
            }

            return 110;
        }

        // =========================
        // ENERGY STATUS
        // =========================
        function getEnergyStatus(deficit) {
            if (deficit < 30) {
                return "GREEN";
            }

            if (deficit < 60) {
                return "LOW";
            }

            return "CRITICAL";
        }

        // =========================
        // BONK PREDICTION
        // =========================
        function predictBonkTime(deficit, IF) {
            var burnRate = estimateCarbBurnRate(IF);

            var remaining = glycogenCapacity - deficit;

            if (remaining <= 0) {
                return 0;
            }

            return (remaining / burnRate) * 60;
        }

        // =========================
        // FUEL ALERT
        // =========================
        function shouldFuelNow(deficit, IF) {
            var status = getEnergyStatus(deficit);

            if (status == "CRITICAL") {
                return true;
            }

            var bonk = predictBonkTime(deficit, IF);

            if (bonk < 20) {
                return true;
            }

            return false;
        }
        // =========================
        // NEXT DEMAND
        // =========================
        function nextDemand(IF, lapDuration) {
            if (IF > 0.90) {
                return "LOW";
            }

            if (IF < 0.60 && lapDuration > 300) {
                return "HIGH";
            }

            if (IF > 0.80) {
                return "MODERATE";
            }

            return "STEADY";
        }
    }
}