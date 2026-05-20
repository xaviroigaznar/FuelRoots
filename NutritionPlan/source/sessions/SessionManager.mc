using Toybox.System;
using Toybox.Weather;

using Session;
using Engine;
using Tracker;

module Session {
    class SessionManager {

        // =====================================
        // CORE
        // =====================================
        var state;
        var profile;

        // =====================================
        // ENGINES
        // =====================================
        var fuelEngine;
        var hydrationEngine;
        var predictionEngine;

        // =====================================
        // TRACKERS
        // =====================================
        var nutritionTracker;

        // =====================================
        // UPDATE TIMERS
        // =====================================

        var lastFuelUpdate;
        var lastPredictionUpdate;

        var powerBuffer;
        var maxBufferSize;

        function initialize(profileData) {
            state = new WorkoutState();
            profile = profileData;

            // =============================
            // ENGINES
            // =============================
            fuelEngine = new Engine.FuelEngine(profile);
            hydrationEngine = new Engine.HydrationEngine(profile);
            predictionEngine = new Engine.PredictionEngine();

            // =============================
            // TRACKERS
            // =============================
            nutritionTracker = new Tracker.NutritionTracker();

            // =============================
            // TIMERS
            // =============================
            lastFuelUpdate = 0;
            lastPredictionUpdate = 0;

            powerBuffer = [];
            maxBufferSize = 30;
        }

        // =====================================
        // MAIN UPDATE
        // =====================================
        function update(info) {
            if (info == null) {
                return;
            }

            // =============================
            // BASE METRICS
            // =============================
            updateBaseMetrics(info);

            var now = System.getTimer();

            // =============================
            // FUEL ENGINE
            // =============================

            if (
                now - lastFuelUpdate
                > 1000
            ) {
                fuelEngine.update(state);

                lastFuelUpdate = now;
            }

            // =============================
            // HYDRATION ENGINE
            // =============================
            hydrationEngine.update(state);

            // =============================
            // NUTRITION
            // =============================
            updateNutritionState();

            // =============================
            // PREDICTIONS
            // =============================

            if (
                now - lastPredictionUpdate
                > 5000
            ) {
                predictionEngine
                    .update(state);

                lastPredictionUpdate =
                    now;
            }
        }

        // =====================================
        // BASE METRICS
        // =====================================
        function updateBaseMetrics(info) {
            state.elapsedTime =
                info.elapsedTime;

            state.currentPower =
                info.currentPower;

            state.calories =
                info.calories;

            // =============================
            // WEATHER
            // =============================
            var weather =
                Weather
                    .getCurrentConditions();

            if (
                weather != null
                && weather.temperature
                    != null
            ) {

                state.temperature =
                    weather.temperature;
            }

            // =============================
            // LAP TIME
            // =============================

            if (
                info has :currentLapTime
            ) {
                state.lapElapsedTime =
                    info.currentLapTime;
            }
        }

        // =====================================
        // NUTRITION STATE
        // =====================================

        function updateNutritionState() {

            // =============================
            // SESSION INTAKE
            // =============================

            state.sessionCarbsIngested =
                nutritionTracker
                    .getSessionCarbs();

            state.lapCarbsIngested =
                nutritionTracker
                    .getLapCarbs();

            // =============================
            // INTAKE RATES
            // =============================

            state.sessionCarbsIngestedPerHour =
                nutritionTracker
                    .getSessionCarbRate(
                        state.elapsedTime
                    );

            state.lapCarbsIngestedPerHour =
                nutritionTracker
                    .getLapCarbRate(
                        state.lapElapsedTime
                    );

            // =============================
            // BURN RATES
            // =============================

            var elapsedHours =
                state.elapsedTime
                / 3600.0;

            if (elapsedHours > 0) {

                state.sessionCarbsBurnedPerHour =
                    state.sessionCarbsBurned
                    / elapsedHours;
            }
            else {

                state.sessionCarbsBurnedPerHour =
                    0;
            }

            var lapHours =
                state.lapElapsedTime
                / 3600.0;

            if (lapHours > 0) {

                state.lapCarbsBurnedPerHour =
                    state.lapCarbsBurned
                    / lapHours;
            }
            else {

                state.lapCarbsBurnedPerHour =
                    0;
            }

            // =============================
            // FUEL DEFICIT
            // =============================
            var carbDeficit =
                state.sessionCarbsBurned
                - state.sessionCarbsIngested;

            if (carbDeficit < 0) {
                carbDeficit = 0;
            }

            state.carbDeficitLabel =
                carbDeficit.format("%.0f")
                + "g";

            // =============================
            // NEXT FUEL
            // =============================
            var minutesUntilFuel =
                nutritionTracker
                    .getNextFuelCountdown(
                        state.relativeIntensity
                    );

            state.nextFuelCountdownLabel =
                Utils.FormatUtils
                    .formatCountdown(
                        minutesUntilFuel
                    );

            // =============================
            // HYDRATION DEFICIT
            // =============================
            state.hydrationDeficitLabel =
                state.hydrationDeficitMl
                    .format("%.0f")
                + "ml";
        }

        // =====================================
        // FUEL EVENT
        // =====================================
        function registerFuel(grams) {

            nutritionTracker
                .registerCarbs(grams);
        }

        // =====================================
        // DRINK EVENT
        // =====================================
        function registerDrink(ml) {
            nutritionTracker
                .registerDrink(ml);

            hydrationEngine
                .registerDrink(ml);
        }

        // =====================================
        // LAP EVENT
        // =====================================
        function onLap() {
            fuelEngine.onLap();

            hydrationEngine.onLap();

            nutritionTracker.resetLap();
        }

        // =====================================
        // STATE
        // =====================================
        function getState() {
            return state;
        }
    }
}