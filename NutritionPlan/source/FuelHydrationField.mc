using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Application;
using Toybox.Activity;
using Toybox.System;

using Session;
using UI;

class FuelHydrationField extends WatchUi.DataField {
    // =====================================
    // CORE
    // =====================================
    var sessionManager;
    var renderer;

    // =====================================
    // ATHLETE CONFIG
    // =====================================
    var ftp;
    var weight;

    // =====================================
    // INIT
    // =====================================
    function initialize() {

        DataField.initialize();

        renderer = new UI.UIRenderer();

        // =============================
        // SETTINGS
        // =============================
        ftp = Application.getApp().getProperty("ftp");
        weight = Application.getApp().getProperty("weight");

        if (ftp == null) {
            ftp = 250;
        }

        if (weight == null) {
            weight = 75;
        }

        // =============================
        // PROFILE
        // =============================
        var profile = new Session.AthleteProfile(ftp, weight);

        sessionManager = new Session.SessionManager(profile);
    }

    function onUpdate(dc) {
        var info = Activity.getActivityInfo();

        // Feed Garmin info directly
        sessionManager.update(info);

        // State
        var state = sessionManager.getState();

        // Draw UI
        drawMainScreen(dc, state);
    }

    function drawMainScreen(dc, state) {

        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();

        // =================================
        // LAYOUT
        // =================================
        var topHeight =
            (height * 50) / 100;

        var bottomHeight =
            height - topHeight;

        var boxWidth =
            width / 2;

        // =================================
        // TOP ROW
        // =================================

        // -----------------------------
        // CARBS BOX
        // -----------------------------

        renderer.drawSummaryBox(
            dc,
            0,
            0,
            boxWidth,
            topHeight,
            "CARBS",
            state.sessionCarbsBurned.format("%.0f") + "g",
            state.sessionCarbsIngested.format("%.0f") + "g",
            state.sessionCarbsIngestedPerHour.format("%.0f") + "g/h",
            state.lapCarbsBurned.format("%.0f") + "g",
            state.lapCarbsIngested.format("%.0f") + "g",
            state.lapCarbsIngestedPerHour.format("%.0f") + "g/h",
            Graphics.COLOR_RED
        );

        // -----------------------------
        // HYDRATION BOX
        // -----------------------------

        renderer.drawSummaryBox(
            dc,
            boxWidth,
            0,
            boxWidth,
            topHeight,
            "HYDRATION",
            state.sessionHydrationLoss.format("%.0f") + "ml",
            state.sessionHydrationDrunk.format("%.0f") + "ml",
            state.sessionHydrationDrunkPerHour.format("%.0f") + "ml/h",
            state.lapHydrationLoss.format("%.0f") + "ml",
            state.lapHydrationDrunk.format("%.0f") + "ml",
            state.lapHydrationDrunkPerHour.format("%.0f") + "ml/h",
            Graphics.COLOR_GREEN
        );

        // =================================
        // BOTTOM LEFT
        // =================================
        var carbDeficitLabel = state.carbsDeficit.format("%.0f") + "g";
        var hydrationDeficitLabel = state.hydrationDeficitMl.format("%.0f") + "ml";

        renderer.drawCountdownBox(
            dc,
            0,
            topHeight,
            boxWidth,
            bottomHeight,
            state.nextDrinkCountdownLabel,
            state.nextFuelCountdownLabel
        );

        // =================================
        // STATUS BOX
        // =================================

        renderer.drawStatusBox(
            dc,
            boxWidth,
            topHeight,
            boxWidth,
            bottomHeight,
            state.statusLabel,
            state.fatiguePercent,
            carbDeficitLabel,
            hydrationDeficitLabel,
            state.bonkTimeLabel,
            state.bonkRiskLabel
        );

        // =================================
        // ALERTS
        // =================================
        if (state.activeAlert != null) {
            renderer.drawAlertOverlay(
                dc,
                state.activeAlert,
                state.alertText,
                Graphics.COLOR_BLUE
            );
        }
    }
}