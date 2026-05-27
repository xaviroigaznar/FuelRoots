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