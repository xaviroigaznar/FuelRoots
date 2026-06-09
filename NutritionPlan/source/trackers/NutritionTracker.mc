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
        // SESSION FLUID
        // =====================================

        function getSessionFluid() {

            return sessionFluidIngestedMl;
        }

        // =====================================
        // LAP FLUID
        // =====================================

        function getLapFluid() {

            return lapFluidIngestedMl;
        }

        // =====================================
        // SESSION INTAKE RATE
        // =====================================

        function getSessionHydrationRate(
            elapsedSeconds
        ) {

            if (elapsedSeconds <= 0) {
                return 0;
            }

            var hours =
                elapsedSeconds / 3600.0;

            return
                sessionFluidIngestedMl / hours;
        }

        // =====================================
        // LAP INTAKE RATE
        // =====================================

        function getLapHydrationRate(
            lapElapsedSeconds
        ) {

            if (lapElapsedSeconds <= 0) {
                return 0;
            }

            var hours =
                lapElapsedSeconds / 3600.0;

            return
                lapFluidIngestedMl / hours;
        }

    }
}