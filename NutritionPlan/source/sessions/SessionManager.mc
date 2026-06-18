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

        var powerBuffer;
        var maxBufferSize;

        // =====================================
        // ALERTS
        // =====================================
        var alertStartTime;

        const MIN_FUEL_ALERT_TIME = 900000; // 15 min
        const MIN_DRINK_ALERT_TIME = 600000; // 10 min

        function initialize(profileData) {
            state = new WorkoutState();
            profile = profileData;

            // =============================
            // ENGINES
            // =============================
            fuelEngine = new Engine.FuelEngine(profile);
            hydrationEngine = new Engine.HydrationEngine(profile);
            predictionEngine = new Engine.PredictionEngine(profile);

            // =============================
            // TRACKERS
            // =============================
            nutritionTracker = new Tracker.NutritionTracker();
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
            fuelEngine.update(state);

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
                predictionEngine
                    .update(state);

            // =============================
            // ALERTS
            // =============================
            // Trigger conditions
            
            if(
                (state.carbsBurnedSinceLastFuel >= SettingsManager.getCHThreshold()) && state.activeAlert == Constants.AlertType.NONE && (System.getTimer() - nutritionTracker.lastCarbIntakeTime) >= MIN_FUEL_ALERT_TIME
            ) {
                if (Attention has :vibrate) {
                    var vibeData =
                    [
                        new Attention.VibeProfile(50, 2000), // On for two seconds
                        new Attention.VibeProfile(0, 1000),  // Off for one second
                        new Attention.VibeProfile(50, 2000), // On for two seconds
                        new Attention.VibeProfile(0, 1000),  // Off for one second
                        new Attention.VibeProfile(50, 2000)  // on for two seconds
                    ];
                    Attention.vibrate(vibeData);
                }
                triggerFuelAlert();
            } else if (
                (state.fluidLostSinceLastDrink >= SettingsManager.getHydrationThreshold()) && state.activeAlert == Constants.AlertType.NONE && (System.getTimer() - nutritionTracker.lastDrinkTime) >= MIN_DRINK_ALERT_TIME
            ) {
                if (Attention has :vibrate) {
                    var vibeData =
                    [
                        new Attention.VibeProfile(50, 2000), // On for two seconds
                        new Attention.VibeProfile(0, 1000),  // Off for one second
                        new Attention.VibeProfile(50, 2000), // On for two seconds
                        new Attention.VibeProfile(0, 1000),  // Off for one second
                        new Attention.VibeProfile(50, 2000)  // on for two seconds
                    ];
                    Attention.vibrate(vibeData);
                }
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

            if (state.carbBurnRate != null) {
                state.minutesUntilFuel = calculateFuelCountdown(state.carbsBurnedSinceLastFuel, state.carbBurnRate);
                state.recommendedCarbs = calculateRecommendedCarbs(state.carbsBurnedSinceLastFuel, state.carbBurnRate);

                state.nextFuelCountdownLabel =
                    Utils.FormatUtils
                        .formatCountdown(
                            state.minutesUntilFuel
                        );
            }
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

            if (state.sweatRate != null) {
                state.minutesUntilDrink = calculateDrinkCountdown(state.fluidLostSinceLastDrink, state.sweatRate);
                state.recommendedDrink = calculateRecommendedDrink(state.fluidLostSinceLastDrink, state.sweatRate);
                
                state.nextDrinkCountdownLabel = 
                    Utils.FormatUtils
                    .formatCountdown(
                        state.minutesUntilDrink
                    );
            }
        }

        // =====================================
        // FUEL COUNTDOWN
        // =====================================
        function calculateFuelCountdown(
            carbsBurnedSinceLastFuel,
            carbBurnRate
        ) {
            var remaining = SettingsManager.getCHThreshold() - carbsBurnedSinceLastFuel;

            if (remaining <= 0) {
                return 0;
            }

            return (remaining / carbBurnRate) * 60;
        }

        // =====================================
        // FUEL RECOMMENDATION
        // =====================================
        function calculateRecommendedCarbs(
            carbDeficit,
            burnRate
        ) {

            var targetWindow = 20.0 / 60.0;

            var futureDemand =
                burnRate * targetWindow;

            var recommendation =
                carbDeficit + futureDemand;

            var multiple = Utils.FormatUtils.roundToNearestMultiple(recommendation, SettingsManager.getCHDosePreference());

            return multiple;
        }

        // =====================================
        // FUEL ALERT
        // =====================================

        function triggerFuelAlert() {

            var now =
                System.getTimer();

            state.activeAlert = Constants.AlertType.FUEL;

            state.alertText =
                "TAKE "
                + state.recommendedCarbs.format("%.0f")
                + "g HC";
            
            alertStartTime = now;
        }

        // =====================================
        // DRINK COUNTDOWN
        // =====================================
        function calculateDrinkCountdown(
            fluidLostSinceLastDrink,
            sweatRate
        ) {
            var remaining = SettingsManager.getHydrationThreshold() - fluidLostSinceLastDrink;

            if (remaining <= 0) {
                return 0;
            }

            return (remaining / sweatRate) * 60;
        }

        // =====================================
        // DRINK RECOMMENDATION
        // =====================================
        function calculateRecommendedDrink(
            deficitMl,
            sweatRate
        ) {

            var targetWindow = 15.0 / 60.0;

            var futureDemand =
                sweatRate * targetWindow;

            var recommendation =
                deficitMl + futureDemand;

            if (recommendation > 250) {
                recommendation = 250;
            }

            var multiple = Utils.FormatUtils.roundToNearestMultiple(recommendation, SettingsManager.getHydrationDosePreference());

            return multiple;
        }

        // =====================================
        // DRINK ALERT
        // =====================================
        function triggerDrinkAlert() {
            var now =
                System.getTimer();

            state.activeAlert = Constants.AlertType.DRINK;

            state.alertText =
                "DRINK "
                + state.recommendedDrink.format("%.0f")
                + "ml";
            
            alertStartTime = now;
        }

        function updateAlertLifecycle() {
            if (state.activeAlert == Constants.AlertType.NONE) {
                return;
            }

            var elapsed =
                System.getTimer()
                - alertStartTime;

            if (elapsed > SettingsManager.getAlertDisplayingTimer()) {
                var activeAlert = state.activeAlert;

                if (activeAlert == Constants.AlertType.FUEL) {
                    confirmFuelIntake();
                } else if (activeAlert == Constants.AlertType.DRINK) {
                    confirmDrinkIntake();
                }

                state.activeAlert = Constants.AlertType.NONE;
                alertStartTime = null;
            }
        }

        // =====================================
        // CONFIRM FUEL
        // =====================================
        function confirmFuelIntake() {
            registerFuel(state.recommendedCarbs);
        }

        // =====================================
        // CONFIRM DRINK
        // =====================================
        function confirmDrinkIntake() {
            registerDrink(state.recommendedDrink);
        }

        // =====================================
        // FUEL EVENT
        // =====================================
        function registerFuel(grams) {
            nutritionTracker
                .registerCarbs(grams);
            
            state.carbsBurnedSinceLastFuel = 0.0;
            
            updateNutritionState();
        }

        // =====================================
        // DRINK EVENT
        // =====================================
        function registerDrink(ml) {
            nutritionTracker
                .registerDrink(ml);
            state.fluidLostSinceLastDrink = 0.0;
            updateNutritionState();
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