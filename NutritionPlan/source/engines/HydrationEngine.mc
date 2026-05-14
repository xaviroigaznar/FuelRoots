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

        var lastDrinkTime;

        // =========================
        // INIT
        // =========================

        function initialize(profile) {
            weight = profile.weight;

            lastDrinkTime = System.getTimer();
        }

        // =========================
        // MAIN UPDATE
        // =========================

        function update(state) {
            var power = state.currentPower;
            var temp = state.temperature;
            var elapsed = state.elapsedTime;

            // Sweat rate (ml/h)
            var sweatRate = calculateSweatRate(
                power,
                temp
            );

            state.sweatRate = sweatRate;

            // Total estimated loss
            var lossMl = (sweatRate / 3600.0) * elapsed;

            state.hydrationDeficitMl = lossMl;

            // Drink recommendation
            state.minutesUntilDrink = calculateNextDrink(power);

            state.drinkCountdownLabel = Utils.FormatUtils.formatCountdown(state.minutesUntilDrink);

            // Status label
            state.hydrationStateLabel = calculateHydrationLabel(lossMl);
        }

        // =========================
        // SWEAT MODEL
        // =========================

        function calculateSweatRate(power, temperature) {

            var rate = 500;

            // =====================
            // POWER
            // =====================
            if (power != null) {
                if (power > 150) {
                    rate += 150;
                }

                if (power > 220) {
                    rate += 200;
                }

                if (power > 280) {
                    rate += 250;
                }
            }

            // =====================
            // TEMPERATURE
            // =====================

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

            // =====================
            // BODY SIZE
            // =====================

            if (weight > 80) {
                rate += 100;
            }

            return rate;
        }

        // =========================
        // DRINK TIMER
        // =========================

        function calculateNextDrink(power) {

            var now = System.getTimer();

            var interval = 900000;

            if (power != null) {
                // Hard effort → drink sooner
                if (power > 220) {
                    interval = 600000;
                }

                if (power > 280) {
                    interval = 420000;
                }
            }

            var remaining =
                (interval - (now - lastDrinkTime)) / 60000.0;

            if (remaining < 0) {
                remaining = 0;
            }

            return remaining;
        }

        // =========================
        // STATUS LABEL
        // =========================

        function calculateHydrationLabel(lossMl) {

            if (lossMl < 500) {
                return "Stable";
            }

            if (lossMl < 1200) {
                return "Drink Soon";
            }

            if (lossMl < 2000) {
                return "Dehydrated";
            }

            return "Critical";
        }

        // =========================
        // EVENT
        // =========================

        function drinkRegistered() {

            lastDrinkTime = System.getTimer();
        }
    }
}