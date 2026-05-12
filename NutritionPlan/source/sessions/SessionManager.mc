using Toybox.System;

using Session;
using Engine;
using Toybox.Weather;

module Session {
    class SessionManager {
        var state;
        var profile;

        var fuelEngine;
        var hydrationEngine;
        var predictionEngine;

        var lastFuelUpdate;
        var lastHydrationUpdate;
        var lastPredictionUpdate;

        function initialize(profileData) {
            state = new WorkoutState();
            profile = profileData;

            fuelEngine = new Engine.FuelEngine(profile);
            hydrationEngine = new Engine.HydrationEngine(profile);
            predictionEngine = new Engine.PredictionEngine();

            lastFuelUpdate = 0;
            lastHydrationUpdate = 0;
            lastPredictionUpdate = 0;
        }

        function update(info) {
            updateBaseMetrics(info);

            var now = System.getTimer();

            // Fuel every 30s
            if (now - lastFuelUpdate > 30000) {
                fuelEngine.update(state);

                lastFuelUpdate = now;
            }

            // Hydration every 60s
            if (now - lastHydrationUpdate > 60000) {
                hydrationEngine.update(state);

                lastHydrationUpdate = now;
            }

            // Prediction every 2 min
            if (now - lastPredictionUpdate > 120000) {
                predictionEngine.update(state);

                lastPredictionUpdate = now;
            }
        }

        function updateBaseMetrics(info) {
            if (info == null) {
                return;
            }

            state.elapsedTime = info.elapsedTime;
            state.calories = info.calories;
            state.currentPower = info.currentPower;
            state.temperature = Weather.getCurrentConditions().temperature;
        }

        function getState() {
            return state;
        }
    }
}