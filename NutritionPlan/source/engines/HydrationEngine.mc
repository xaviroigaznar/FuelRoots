module Engine {

    using Toybox.System;

    class HydrationEngine {

        // =========================
        // ATHLETE PROFILE
        // =========================

        var weight;

        // =========================
        // HYDRATION STATE
        // =========================

        var totalFluidLossMl = 0.0;
        var lapFluidLossMl = 0.0;

        var totalFluidIntakeMl = 0.0;
        var lapFluidIntakeMl = 0.0;

        // =====================================
        // TIMERS
        // =====================================

        var lastElapsedTime = 0;
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
            var ri = state.relativeIntensity;
            var temp = state.temperature;
            var elapsed = state.elapsedTime;

            // First update
            if (lastElapsedTime == 0) {

                lastElapsedTime = elapsed;
                return;
            }

            var deltaSeconds =
                (elapsed - lastElapsedTime)
                / 1000.0;

            // =================================
            // SWEAT RATE
            // =================================
            var sweatRate = calculateSweatRate(ri, temp);

            state.sweatRate = sweatRate;

            
            // =================================
            // FLUID LOSS
            // =================================
            updateFluidLoss(
                sweatRate,
                deltaSeconds
            );

            // =================================
            // HYDRATION DEFICIT
            // =================================

            var deficit =
                totalFluidLossMl
                - totalFluidIntakeMl;

            if (deficit < 0) {
                deficit = 0;
            }

            // =================================
            // DRINK TIMING
            // =================================

            var drinkCountdown =
                calculateNextDrink(ri);

            // =================================
            // EXPORT TO STATE
            // =================================

            state.hydrationDeficitMl =
                deficit;

            state.minutesUntilDrink =
                drinkCountdown;

            state.drinkCountdownLabel =
                Utils.FormatUtils
                    .formatCountdown(
                        drinkCountdown
                    );

            state.hydrationStateLabel =
                calculateHydrationLabel(
                    deficit
                );

            lastElapsedTime =
                elapsed;
        }

        // =====================================
        // FLUID LOSS
        // =====================================

        function updateFluidLoss(
            sweatRate,
            deltaSeconds
        ) {

            var lossIncrement =
                (sweatRate / 3600.0)
                * deltaSeconds;

            totalFluidLossMl +=
                lossIncrement;

            lapFluidLossMl +=
                lossIncrement;
        }

        // =========================
        // SWEAT MODEL
        // =========================

        function calculateSweatRate(relativeIntensity, temperature) {
            // Base sweat rate
            var rate = 500;

            // Intensity scaling
            rate += relativeIntensity * 700;

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

            // Weight scaling
            rate += (weight - 70) * 2;

            // Clamp minimum
            if (rate < 300) {
                rate = 300;
            }

            return rate;
        }

        // =========================
        // DRINK TIMER
        // =========================

        function calculateNextDrink(relativeIntensity) {
            var now = System.getTimer();

            var interval = 900000;

            if (relativeIntensity != null) {
                // Hard effort → drink sooner
                if (relativeIntensity > 0.8) {
                    interval = 420000;
                } else if (relativeIntensity > 0.65) {
                    interval = 600000;
                }
            }

            var remaining = (interval - (now - lastDrinkTime)) / 60000.0;

            if (remaining < 0) {
                remaining = 0;
            }

            return remaining;
        }

        // =========================
        // HYDRATION STATUS
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

        // =====================================
        // DRINK EVENT
        // =====================================
        function registerDrink(ml) {

            totalFluidIntakeMl += ml;
            lapFluidIntakeMl += ml;

            lastDrinkTime =
                System.getTimer();
        }

        // =====================================
        // LAP EVENT
        // =====================================
        function onLap() {
            lapFluidLossMl = 0;
            lapFluidIntakeMl = 0;
        }
    }
}