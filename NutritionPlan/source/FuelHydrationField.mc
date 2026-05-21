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
        // ALERTS
        // =================================
        if (state.pendingFuelAlert) {
            renderer.drawAlertOverlay(
                dc,
                "FUEL NOW",
                state.fuelAlertText,
                Graphics.COLOR_ORANGE
            );
        }
        else if (state.pendingDrinkAlert) {
            renderer.drawAlertOverlay(
                dc,
                "DRINK NOW",
                state.drinkAlertText,
                Graphics.COLOR_BLUE
            );
        }

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
            Graphics.COLOR_GREEN
        );

        // =================================
        // BOTTOM LEFT
        // =================================

        renderer.drawTelemetryBox(
            dc,
            0,
            topHeight,
            telemetryWidth,
            bottomHeight,
            state.drinkCountdownLabel,
            state.hydrationDeficitLabel,
            state.nextFuelCountdownLabel,
            state.carbDeficitLabel
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
            state.bonkTimeLabel,
            state.bonkRiskLabel
        );
    }

    // =====================================
    // USER INPUT
    // =====================================
    function onKey(keyEvent) {

        var state =
            sessionManager.getState();

        // =============================
        // START BUTTON
        // =============================

        if (
            keyEvent.getKey()
            == WatchUi.KEY_START
        ) {

            // =========================
            // FUEL ALERT
            // =========================

            if (
                state.pendingFuelAlert
            ) {

                sessionManager
                    .confirmFuelIntake();

                WatchUi.requestUpdate();

                return true;
            }

            // =========================
            // DRINK ALERT
            // =========================

            if (
                state.pendingDrinkAlert
            ) {

                sessionManager
                    .confirmDrinkIntake();

                WatchUi.requestUpdate();

                return true;
            }
        }

        return false;
    }
}