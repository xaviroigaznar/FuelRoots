module Engine {

    using Toybox.System;

    class HydrationEngine {

        // =========================
        // CONFIG
        // =========================
        var weight;

        // =========================
        // STATE
        // =========================
        var lastDrinkTime = 0;

        // =========================
        // INIT
        // =========================
        function initialize(profile) {
            weight = profile.weight;
        }

        function update(state) {
            var ifValue = state.ifValue;
            var temp = state.temperature;

            state.hydrationRate = hydrationRate(ifValue, temp);
            state.hydrationRisk = hydrationRisk(ifValue, temp);
        }

        // =========================
        // HYDRATION RATE
        // =========================
        function hydrationRate(IF, temperature) {
            var rate = 500;

            // BASE POR IF
            if (IF < 0.65) {
                rate = 500;
            }
            else if (IF < 0.80) {
                rate = 650;
            }
            else if (IF < 0.90) {
                rate = 800;
            }
            else {
                rate = 1000;
            }

            // AJUSTE TEMPERATURA
            if (temperature != null) {

                if (temperature > 20) {
                    rate += 100;
                }

                if (temperature > 28) {
                    rate += 200;
                }

                if (temperature > 35) {
                    rate += 300;
                }
            }

            // AJUSTE PESO
            if (weight > 80) {
                rate += 100;
            }

            return rate;
        }

        // =========================
        // DRINK TIMER
        // =========================
        function nextDrinkCountdown(IF) {
            var now = System.getTimer();

            var interval = 600000;

            if (IF > 0.8) {
                interval = 420000;
            }

            if (IF > 0.9) {
                interval = 300000;
            }

            return (interval - (now - lastDrinkTime)) / 1000;
        }

        // =========================
        // HYDRATION RISK
        // =========================
        function hydrationRisk(IF, temperature) {
            var risk = "LOW";

            if (IF > 0.85) {
                risk = "MODERATE";
            }

            if (temperature != null && temperature > 28) {
                risk = "HIGH";
            }

            if (IF > 0.90 && temperature != null && temperature > 30) {
                risk = "CRITICAL";
            }

            return risk;
        }

        // =========================
        // EVENT
        // =========================
        function drinkRegistered() {
            lastDrinkTime = System.getTimer();
        }
    }
}