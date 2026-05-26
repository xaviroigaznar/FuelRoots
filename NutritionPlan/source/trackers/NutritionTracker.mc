module Tracker {

    using Toybox.System;
    using Utils;

    class NutritionTracker {

        // =====================================
        // SESSION TOTALS
        // =====================================

        var sessionCarbsIngested;
        var sessionFluidIngestedMl;

        // =====================================
        // LAP TOTALS
        // =====================================

        var lapCarbsIngested;
        var lapFluidIngestedMl;

        // =====================================
        // TIMERS
        // =====================================

        var lastCarbIntakeTime;
        var lastDrinkTime;

        // =====================================
        // INIT
        // =====================================

        function initialize() {

            sessionCarbsIngested = 0;
            sessionFluidIngestedMl = 0;

            lapCarbsIngested = 0;
            lapFluidIngestedMl = 0;

            var now = System.getTimer();

            lastCarbIntakeTime = now;
            lastDrinkTime = now;
        }

        // =====================================
        // CARB INGESTION
        // =====================================

        function registerCarbs(grams) {

            sessionCarbsIngested += grams;
            lapCarbsIngested += grams;

            lastCarbIntakeTime =
                System.getTimer();
        }

        // =====================================
        // DRINK INGESTION
        // =====================================

        function registerDrink(ml) {

            sessionFluidIngestedMl += ml;
            lapFluidIngestedMl += ml;

            lastDrinkTime =
                System.getTimer();
        }

        // =====================================
        // LAP RESET
        // =====================================

        function resetLap() {

            lapCarbsIngested = 0;
            lapFluidIngestedMl = 0;
        }

        // =====================================
        // SESSION CARBS
        // =====================================

        function getSessionCarbs() {

            return sessionCarbsIngested;
        }

        // =====================================
        // LAP CARBS
        // =====================================

        function getLapCarbs() {

            return lapCarbsIngested;
        }

        // =====================================
        // SESSION INTAKE RATE
        // =====================================

        function getSessionCarbRate(
            elapsedSeconds
        ) {

            if (elapsedSeconds <= 0) {
                return 0;
            }

            var hours =
                elapsedSeconds / 3600.0;

            return
                sessionCarbsIngested / hours;
        }

        // =====================================
        // LAP INTAKE RATE
        // =====================================

        function getLapCarbRate(
            lapElapsedSeconds
        ) {

            if (lapElapsedSeconds <= 0) {
                return 0;
            }

            var hours =
                lapElapsedSeconds / 3600.0;

            return
                lapCarbsIngested / hours;
        }

        // =====================================
        // NEXT FUEL COUNTDOWN
        // =====================================

        function getNextFuelCountdown(
            relativeIntensity
        ) {

            var interval = 1800000;

            // Hard sessions fuel sooner
            if (relativeIntensity > 0.75) {
                interval = 1200000;
            }

            if (relativeIntensity > 0.90) {
                interval = 900000;
            }

            var now =
                System.getTimer();

            var remainingMinutes =
                (interval -
                (now - lastCarbIntakeTime))
                / 60000.0;

            if (remainingMinutes < 0) {
                remainingMinutes = 0;
            }

            return remainingMinutes;
        }
    }
}