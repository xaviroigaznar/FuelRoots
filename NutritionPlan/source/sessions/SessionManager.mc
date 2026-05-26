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
        var fuelAlertCooldown;
        var drinkAlertCooldown;

        var lastFuelAlertTime;
        var lastDrinkAlertTime;
        var fuelAlertStartTime;
        var drinkAlertStartTime;

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

            lastFuelAlertTime = 0;
            lastDrinkAlertTime = 0;

            // 10 min cooldowns
            fuelAlertCooldown =
                60000;

            drinkAlertCooldown =
                60000;

            // =============================
            // INITIAL STATE
            // =============================

            state.pendingFuelAlert =
                false;

            state.pendingDrinkAlert =
                false;
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
            processAlerts();
            updateFuelAlertLifecycle();
            updateDrinkAlertLifecycle();
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
            // FUEL DEFICIT
            // =============================
            var carbDeficit =
                state.sessionCarbsBurned
                - state.sessionCarbsIngested;

            if (carbDeficit < 0) {
                carbDeficit = 0;
            }

            state.carbsDeficit = carbDeficit;

            // =============================
            // NEXT FUEL
            // =============================

            state.nextFuelCountdownLabel =
                Utils.FormatUtils
                    .formatCountdown(
                        nutritionTracker.getNextFuelCountdown(state.relativeIntensity)
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
        // ALERT PROCESSING
        // =====================================

        function processAlerts() {
            processFuelAlert();

            processDrinkAlert();
        }

        // =====================================
        // FUEL ALERT
        // =====================================

        function processFuelAlert() {

            var now =
                System.getTimer();

            // Already active
            if (
                state.pendingFuelAlert
            ) {
                return;
            }

            // Cooldown
            if (
                now - lastFuelAlertTime
                < fuelAlertCooldown
            ) {
                return;
            }

            // Trigger conditions
            if(
                state.minutesUntilFuel <= 0 || state.carbsDeficit > 2

            ) {

                state.pendingFuelAlert =
                    true;

                state.fuelAlertText =
                    "Take 30g carbs";

                lastFuelAlertTime =
                    now;
                
                fuelAlertStartTime = now;
            }
        }

        // =====================================
        // DRINK ALERT
        // =====================================
        function processDrinkAlert() {

            var now =
                System.getTimer();

            // Already active
            if (
                state.pendingDrinkAlert
            ) {
                return;
            }

            // Cooldown
            if (
                now - lastDrinkAlertTime
                < drinkAlertCooldown
            ) {
                return;
            }

            // Trigger conditions
            if (
                state.minutesUntilDrink <= 0
                || state.hydrationDeficitMl
                    > 4
            ) {

                state.pendingDrinkAlert =
                    true;

                state.drinkAlertText =
                    "Drink 250ml";

                lastDrinkAlertTime =
                    now;
                
                drinkAlertStartTime = now;
            }
        }

        function updateDrinkAlertLifecycle() {
            if (drinkAlertStartTime == null) {
                return;
            }

            var elapsed =
                System.getTimer()
                - drinkAlertStartTime;

            // 8 seconds
            if (elapsed > 8000) {
                drinkAlertStartTime = null;
                confirmDrinkIntake();
            }
        }

        function updateFuelAlertLifecycle() {
            if (fuelAlertStartTime == null) {
                return;
            }

            var elapsed =
                System.getTimer()
                - fuelAlertStartTime;

            // 8 seconds
            if (elapsed > 8000) {
                fuelAlertStartTime = null;
                confirmFuelIntake();
            }
        }

        // =====================================
        // CONFIRM FUEL
        // =====================================
        function confirmFuelIntake() {

            registerFuel(30);

            state.pendingFuelAlert =
                false;
        }

        // =====================================
        // CONFIRM DRINK
        // =====================================
        function confirmDrinkIntake() {

            registerDrink(250);

            state.pendingDrinkAlert =
                false;
        }

        // =====================================
        // DISMISS ALERTS
        // =====================================
        function dismissFuelAlert() {

            state.pendingFuelAlert =
                false;
        }

        function dismissDrinkAlert() {

            state.pendingDrinkAlert =
                false;
        }

        // =====================================
        // FUEL EVENT
        // =====================================
        function registerFuel(grams) {

            nutritionTracker
                .registerCarbs(grams);
            
            fuelEngine
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