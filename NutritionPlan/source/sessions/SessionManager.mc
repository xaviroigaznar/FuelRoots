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

        // =====================================
        // ALERTS
        // =====================================
        var alertCooldown;

        var alertStartTime;

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

            // =============================
            // ALERTS
            // =============================

            // 10 min cooldowns
            alertCooldown =
                60000;
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

            // =============================
            // ALERTS
            // =============================
            // Trigger conditions
            if(
                state.minutesUntilFuel <= 0 || state.carbsDeficit > 2 && state.activeAlert == null
            ) {
                triggerFuelAlert();
            } else if (
                state.minutesUntilDrink <= 0 || state.hydrationDeficitMl > 4 && state.activeAlert == null
            ) {
                triggerDrinkAlert();
            }
            updateAlertLifecycle();
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
            } else {
                state.lapElapsedTime = state.elapsedTime;
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
            
            state.sessionHydrationDrunk = nutritionTracker.getSessionFluid();

            state.lapCarbsIngested =
                nutritionTracker
                    .getLapCarbs();
            
            state.lapHydrationDrunk = nutritionTracker.getLapFluid();

            // =============================
            // INTAKE RATES
            // =============================

            state.sessionCarbsIngestedPerHour =
                nutritionTracker
                    .getSessionCarbRate(
                        state.elapsedTime
                    );
            
            state.sessionHydrationDrunkPerHour = nutritionTracker.getSessionHydrationRate(state.elapsedTime);

            state.lapCarbsIngestedPerHour =
                nutritionTracker
                    .getLapCarbRate(
                        state.lapElapsedTime
                    );
            
            state.lapHydrationDrunkPerHour = nutritionTracker.getLapHydrationRate(state.elapsedTime);

            // =============================
            // BURN RATES
            // =============================

            var elapsedHours =
                state.elapsedTime
                / 3600000.0;

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
                / 3600000.0;

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
            // FUEL LOGIC
            // =============================
            var carbDeficit =
                fuelEngine.getTotalCarbsBurned()
                - nutritionTracker.getSessionCarbs();

            if (carbDeficit < 0) {
                carbDeficit = 0;
            }

            state.carbsDeficit = carbDeficit;

            state.minutesUntilFuel = nutritionTracker.getNextFuelCountdown(state.relativeIntensity);

            state.nextFuelCountdownLabel =
                Utils.FormatUtils
                    .formatCountdown(
                        state.minutesUntilFuel
                    );
            

            // =============================
            // HYDRATION DEFICIT
            // =============================
            var hydrationDeficit =
                hydrationEngine.getTotalFluidLoss()
                - nutritionTracker.getSessionFluid();

            if (hydrationDeficit < 0) {
                hydrationDeficit = 0;
            }

            state.hydrationDeficitMl = hydrationDeficit;

            state.minutesUntilDrink = nutritionTracker.getNextDrinkCountdown(state.relativeIntensity);
            
            state.nextDrinkCountdownLabel = 
                Utils.FormatUtils
                .formatCountdown(
                    state.minutesUntilDrink
                );
        }

        // =====================================
        // FUEL ALERT
        // =====================================

        function triggerFuelAlert() {

            var now =
                System.getTimer();

            state.activeAlert =
                "FUEL";

            state.alertText =
                "Take 30g carbs";
            
            alertStartTime = now;
        }

        // =====================================
        // DRINK ALERT
        // =====================================
        function triggerDrinkAlert() {

            var now =
                System.getTimer();

            state.activeAlert =
                "DRINK";

            state.alertText =
                "Drink 250ml";
            
            alertStartTime = now;
        }

        function updateAlertLifecycle() {
            if (state.activeAlert == null) {
                return;
            }

            var elapsed =
                System.getTimer()
                - alertStartTime;

            // 8 seconds
            if (elapsed > 8000) {
                var activeAlert = state.activeAlert;
                state.activeAlert = null;
                alertStartTime = null;
                if (activeAlert == "FUEL") {
                    confirmFuelIntake();
                } else if (activeAlert == "DRINK") {
                    confirmDrinkIntake();
                }
            }
        }

        // =====================================
        // CONFIRM FUEL
        // =====================================
        function confirmFuelIntake() {
            registerFuel(30);
        }

        // =====================================
        // CONFIRM DRINK
        // =====================================
        function confirmDrinkIntake() {
            registerDrink(250);
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