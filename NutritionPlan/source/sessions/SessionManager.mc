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

        var powerBuffer;
        var maxBufferSize;

        function initialize(profileData) {
            state = new WorkoutState();
            profile = profileData;

            fuelEngine = new Engine.FuelEngine(profile);
            hydrationEngine = new Engine.HydrationEngine(profile);
            predictionEngine = new Engine.PredictionEngine();

            lastFuelUpdate = 0;
            lastHydrationUpdate = 0;
            lastPredictionUpdate = 0;

            powerBuffer = [];
            maxBufferSize = 30;
        }

        function update(info) {
            updateBaseMetrics(info);

            var now = System.getTimer();

            // Fuel every 30s
            if (now - lastFuelUpdate > 30000) {
                fuelEngine.update(state);

                lastFuelUpdate = now;
            }

            // Hydration every second
            hydrationEngine.update(state);

            lastHydrationUpdate = now;

            // Prediction every 60s
            if (now - lastPredictionUpdate > 60000) {
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

            updateRollingPower(info.currentPower);
        }

        function updateRollingPower(currentPower) {
            if (currentPower == null) {
                return;
            }

            powerBuffer.add(currentPower);

            // Keep only latest 30 samples
            if (powerBuffer.size() > maxBufferSize) {
                powerBuffer.remove(0);
            }

            var total = 0;

            for (var i = 0; i < powerBuffer.size(); i += 1) {
                total += powerBuffer[i];
            }

            state.rollingPower = total / powerBuffer.size();

            // Relative intensity
            if (profile.ftp > 0) {
                state.relativeIntensity = state.rollingPower / profile.ftp;
            }
            else {

                state.relativeIntensity = 0;
            }
        }

        function getState() {
            return state;
        }
    }
}