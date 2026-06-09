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
        var recommendedCarbs;
        var recommendedDrink;

        const CARBS_THRESHOLD = 30;
        const HYDRATION_THRESHOLD = 20;

        const CARBS_MULTIPLE = 30;
        const HYDRATION_MULTIPLE = 125;

        const MIN_FUEL_ALERT_TIME = 900000; // 15 min
        const MIN_DRINK_ALERT_TIME = 60000; // 10 min

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

            // =============================
            // ALERTS
            // =============================
            recommendedCarbs = 0;
            recommendedDrink = 0;
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
                (fuelEngine.carbsBurnedSinceLastFuel > CARBS_THRESHOLD) && state.activeAlert == Constants.AlertType.NONE && (System.getTimer() - nutritionTracker.lastCarbIntakeTime) >= MIN_FUEL_ALERT_TIME
            ) {
                triggerFuelAlert();
            } else if (
                (hydrationEngine.fluidLostSinceLastDrink > HYDRATION_THRESHOLD) && state.activeAlert == Constants.AlertType.NONE && (System.getTimer() - nutritionTracker.lastDrinkTime) >= MIN_DRINK_ALERT_TIME
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

            if (state.carbBurnRate != null) {
                state.minutesUntilFuel = calculateFuelCountdown(fuelEngine.carbsBurnedSinceLastFuel, state.carbBurnRate);
                recommendedCarbs = calculateRecommendedCarbs(carbDeficit, state.carbBurnRate);

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
                state.minutesUntilDrink = calculateDrinkCountdown(hydrationEngine.fluidLostSinceLastDrink, state.sweatRate);
                recommendedDrink = calculateRecommendedDrink(hydrationDeficit, state.sweatRate);
                
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
            var remaining = CARBS_THRESHOLD - carbsBurnedSinceLastFuel;

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

            var multiple = Utils.FormatUtils.roundToNearestMultiple(recommendation, CARBS_MULTIPLE);

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
                + recommendedCarbs.format("%.0f")
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
            var remaining = HYDRATION_THRESHOLD - fluidLostSinceLastDrink;

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

            if (recommendation > 750) {
                recommendation = 750;
            }

            var multiple = Utils.FormatUtils.roundToNearestMultiple(recommendation, HYDRATION_MULTIPLE);

            return multiple;
        }

        // =====================================
        // DRINK ALERT
        // =====================================
        function triggerDrinkAlert() {
            System.println(
                "Fluid since drink: "
                + hydrationEngine.fluidLostSinceLastDrink
            );

            System.println(
                "Hydration deficit: "
                + state.hydrationDeficitMl
            );
            var now =
                System.getTimer();

            state.activeAlert = Constants.AlertType.DRINK;

            state.alertText =
                "DRINK "
                + recommendedDrink.format("%.0f")
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

            System.println(
                "Alert active: "
                + state.activeAlert
                + " elapsed="
                + elapsed
            );
            // 8 seconds
            if (elapsed > 8000) {
                System.println("CONFIRMING ALERT");
                var activeAlert = state.activeAlert;
                if (activeAlert == Constants.AlertType.FUEL) {
                    confirmFuelIntake();
                } else if (activeAlert == Constants.AlertType.DRINK) {
                    System.println("CONFIRM DRINK");
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
            registerFuel(recommendedCarbs);
        }

        // =====================================
        // CONFIRM DRINK
        // =====================================
        function confirmDrinkIntake() {
            System.println(
    "confirmDrinkIntake() called"
);
            registerDrink(recommendedDrink);
        }

        // =====================================
        // FUEL EVENT
        // =====================================
        function registerFuel(grams) {
            nutritionTracker
                .registerCarbs(grams);
            
            fuelEngine.resetCarbsBurnedSinceLastFuel();
            
            updateNutritionState();
        }

        // =====================================
        // DRINK EVENT
        // =====================================
        function registerDrink(ml) {
            nutritionTracker
                .registerDrink(ml);
            hydrationEngine.resetFluidLostSinceLastDrink();
            
            System.println(
                "After reset: "
                + hydrationEngine.fluidLostSinceLastDrink
            );
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