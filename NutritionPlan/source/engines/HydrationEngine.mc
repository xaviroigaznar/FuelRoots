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

        // =====================================
        // TIMERS
        // =====================================

        var lastElapsedTime = 0;

        // =========================
        // INIT
        // =========================

        function initialize(profile) {
            weight = profile.weight;
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
            var sweatRate = SettingsManager.getSweatRate();

            if (sweatRate == null) {
                sweatRate = calculateSweatRate(ri, temp);
                state.sweatRate = sweatRate;
            }

            
            // =================================
            // FLUID LOSS
            // =================================
            updateFluidLoss(
                sweatRate,
                deltaSeconds,
                state
            );

            // =================================
            // EXPORT TO STATE
            // =================================

            state.sessionHydrationLoss =
                totalFluidLossMl;
            
            state.lapHydrationLoss = lapFluidLossMl;

            state.hydrationStateLabel =
                calculateHydrationLabel(
                    state.hydrationDeficitMl
                );

            lastElapsedTime =
                elapsed;
        }

        // =====================================
        // FLUID LOSS
        // =====================================

        function updateFluidLoss(
            sweatRate,
            deltaSeconds,
            state
        ) {

            var lossIncrement =
                (sweatRate / 3600.0)
                * deltaSeconds;

            totalFluidLossMl +=
                lossIncrement;
            
            state.fluidLostSinceLastDrink += lossIncrement;

            lapFluidLossMl +=
                lossIncrement;
        }

        // =========================
        // SWEAT MODEL
        // =========================

        function calculateSweatRate(relativeIntensity, temperature) {
            // Base sweat rate
            var rate = 0;
            if (relativeIntensity > 0) {
                if (temperature != null) {
                    rate = (weight * (0.004 + (0.008 * relativeIntensity)) * (1.0 + (0.02 * (temperature - 20.0)))) * 1000;
                } else {
                    rate = (weight * (0.004 + (0.008 * relativeIntensity))) * 1000;
                }
            } else {
                if (temperature != null) {
                    rate = (weight * 0.009 * (1.0 + (0.02 * (temperature - 20.0)))) * 1000;
                } else {
                    rate = (weight * 0.009) * 1000;
                }
            }

            // =====================
            // BODY SIZE
            // =====================
            // Clamp minimum
            if (rate < 125) {
                rate = 125;
            }

            return rate;
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

        function getTotalFluidLoss() {
            return totalFluidLossMl;
        }
    
        function getLapFluidLoss() {
            return lapFluidLossMl;
        }

        // =====================================
        // LAP EVENT
        // =====================================
        function onLap() {
            lapFluidLossMl = 0;
        }
    }
}