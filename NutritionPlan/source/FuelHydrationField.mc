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
            (height * 40) / 100;

        var bottomHeight =
            height - topHeight;

        var summaryWidth =
            width / 2;

        var telemetryWidth =
            (width * 65) / 100;

        var statusWidth =
            width - telemetryWidth;

        // =================================
        // TOP ROW
        // =================================

        // -----------------------------
        // SESSION BOX
        // -----------------------------

        renderer.drawSummaryBox(
            dc,
            0,
            0,
            summaryWidth,
            topHeight,
            "TOTAL",
            state.sessionCarbsBurnedPerHour,
            state.sessionCarbsIngestedPerHour,
            state.sessionCarbsIngested,
            state.sessionHydrationLoss,
            Graphics.COLOR_RED
        );

        // -----------------------------
        // LAP BOX
        // -----------------------------

        renderer.drawSummaryBox(
            dc,
            summaryWidth,
            0,
            summaryWidth,
            topHeight,
            "LAP",
            state.lapCarbsBurnedPerHour,
            state.lapCarbsIngestedPerHour,
            state.lapCarbsIngested,
            state.lapHydrationLoss,
            Graphics.COLOR_GREEN
        );

        // =================================
        // BOTTOM LEFT
        // =================================
        var carbDeficitLabel = state.carbsDeficit.format("%.0f") + "g";

        renderer.drawTelemetryBox(
            dc,
            0,
            topHeight,
            telemetryWidth,
            bottomHeight,
            state.nextDrinkCountdownLabel,
            state.hydrationDeficitLabel,
            state.nextFuelCountdownLabel,
            carbDeficitLabel
        );

        // =================================
        // STATUS BOX
        // =================================

        renderer.drawStatusBox(
            dc,
            telemetryWidth,
            topHeight,
            statusWidth,
            bottomHeight,
            state.statusLabel,
            state.fatiguePercent,
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