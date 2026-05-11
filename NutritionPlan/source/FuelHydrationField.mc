using Toybox.WatchUi;
using Toybox.Activity;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Attention;
using Toybox.Application;
using Toybox.Math;
using Toybox.Sensor;

class FuelHydrationField extends WatchUi.DataField {
    using Toybox.Application;
    var engine;

    // =========================
    // CONFIG
    // =========================
    var ftp;
    var weight;

    // =========================
    // INIT
    // =========================
    function initialize() {
        DataField.initialize();

        var ftp = Application.getApp().getProperty("ftp");
        var weight = Application.getApp().getProperty("weight");

        if (ftp == null) { ftp = 250; }
        if (weight == null) { weight = 70; }

        engine = new NutritionEngine(ftp, weight);
    }

    // =========================
    // DRAW BOX
    // =========================
    function drawBox(dc, x, y, w, h, bgColor) {
        dc.setColor(bgColor, bgColor);
        dc.fillRectangle(x, y, w, h);
    }

    // =========================
    // MAIN
    // =========================
    function onUpdate(dc) {
        var info = Activity.getActivityInfo();

        engine.update(info);

        var IF = engine.getIF();
        var carbsTarget = engine.carbsPerHour();
        var hydration = engine.hydrationRate();

        var totalKj = engine.getTotalKj();
        var lapKj = engine.getLapKj();

        var nextDrink = engine.nextDrinkCountdown();

        var energyStatus = engine.getEnergyStatus(info.elapsedTime);

        var bonkTime = engine.predictBonkTime(info.elapsedTime);

        var fuelNow = engine.shouldFuelNow(info.elapsedTime);

        // =========================
        // BASE
        // =========================
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var w = dc.getWidth();

        // =========================
        // HEADER
        // =========================
        dc.drawText(
            w/2,
            8,
            Graphics.FONT_SYSTEM_MEDIUM,
            "THE ATHLETE'S ROOTS",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // =========================
        // TOP BOXES
        // =========================
        var boxY = 35;
        var boxW = (w / 2) - 12;
        var boxH = 90;

        drawMetricBox(
            dc,
            5,
            boxY,
            boxW,
            boxH,
            Graphics.COLOR_BLUE,
            "Bloque",
            IF.format("%.2f"),
            lapKj.format("%.0f")
        );

        drawMetricBox(
            dc,
            w/2 + 5,
            boxY,
            boxW,
            boxH,
            Graphics.COLOR_GREEN,
            "Total",
            IF.format("%.2f"),
            totalKj.format("%.0f")
        );
        
        // =========================
        // ALERTA
        // =========================
        var alertY = 140;

        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK);

        dc.fillRectangle(5, alertY, w - 10, 28);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_YELLOW);

        dc.drawText(
            15,
            alertY + 3,
            Graphics.FONT_SMALL,
            "Alerta en",
            Graphics.TEXT_JUSTIFY_LEFT
        );

        // =========================
        // ENERGY STATUS
        // =========================
        var statusColor;

        if (energyStatus == "GREEN") {
            statusColor = Graphics.COLOR_GREEN;
        } else if (energyStatus == "LOW") {
            statusColor = Graphics.COLOR_YELLOW;
        } else {
            statusColor = Graphics.COLOR_RED;
        }

        // BOX BORDER
        dc.setColor(statusColor, Graphics.COLOR_BLACK);

        dc.drawRectangle(5, 175, w - 10, 40);

        // TEXT (FORZAR BLANCO)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        dc.drawText(
            w/2,
            183,
            Graphics.FONT_MEDIUM,
            energyStatus,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        dc.drawText(
            10,
            225,
            Graphics.FONT_SMALL,
            "BONK " + bonkTime.format("%.0f") + " min",
            Graphics.TEXT_JUSTIFY_LEFT
        );

        if (fuelNow) {
            var vibe = [
                new Attention.VibeProfile(200, 100),
                new Attention.VibeProfile(200, 100),
                new Attention.VibeProfile(400, 100)
            ];

            Attention.vibrate(vibe);

            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);

            dc.drawText(
                w/2,
                260,
                Graphics.FONT_LARGE,
                "FUEL NOW",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }

/*
        // =========================
        // ALERT CONTENT
        // =========================
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        dc.drawText(
            10,
            185,
            Graphics.FONT_LARGE,
            "BEBER",
            Graphics.TEXT_JUSTIFY_LEFT
        );

        dc.drawText(
            w - 10,
            185,
            Graphics.FONT_LARGE,
            nextDrink.format("%.0f"),
            Graphics.TEXT_JUSTIFY_RIGHT
        );

        dc.drawText(
            10,
            225,
            Graphics.FONT_LARGE,
            "FUEL",
            Graphics.TEXT_JUSTIFY_LEFT
        );

        dc.drawText(
            w - 10,
            225,
            Graphics.FONT_LARGE,
            carbsTarget.format("%.0f") + " g/h",
            Graphics.TEXT_JUSTIFY_RIGHT
        ); */

        // =========================
        // BOTTOM BOXES
        // =========================
        var bottomY = 285;
        var bottomH = 180;

        drawBottomBox(
            dc,
            5,
            bottomY,
            boxW,
            bottomH,
            Graphics.COLOR_RED,
            "CHO(g)",
            "0"
        );

        drawBottomBox(
            dc,
            w/2 + 5,
            bottomY,
            boxW,
            bottomH,
            Graphics.COLOR_BLUE,
            "AGUA(ml)",
            hydration.format("%.0f")
        );
    }

    function drawMetricBox(dc, x, y, w, h, color, title, ifValue, kjValue) {
        // Fondo negro
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(x, y, w, h);

        // Borde
        dc.setColor(color, Graphics.COLOR_BLACK);
        dc.drawRectangle(x, y, w, h);

        // Header
        dc.fillRectangle(x, y, w, 24);

        // Título
        dc.setColor(Graphics.COLOR_WHITE, color);

        dc.drawText(
            x + 10,
            y + 2,
            Graphics.FONT_SMALL,
            title,
            Graphics.TEXT_JUSTIFY_LEFT
        );

        // Contenido
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        dc.drawText(
            x + 10,
            y + 35,
            Graphics.FONT_MEDIUM,
            "IF " + ifValue,
            Graphics.TEXT_JUSTIFY_LEFT
        );

        dc.drawText(
            x + 10,
            y + 62,
            Graphics.FONT_MEDIUM,
            "kJ " + kjValue,
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }

    function drawBottomBox(dc, x, y, w, h, color, title, value) {

        // Fondo negro
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(x, y, w, h);

        // Borde
        dc.setColor(color, Graphics.COLOR_BLACK);
        dc.drawRectangle(x, y, w, h);

        // Header
        dc.fillRectangle(x, y, w, 26);

        // Título
        dc.setColor(Graphics.COLOR_WHITE, color);

        dc.drawText(
            x + 8,
            y + 3,
            Graphics.FONT_SMALL,
            title,
            Graphics.TEXT_JUSTIFY_LEFT
        );

        // Número grande
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        dc.drawText(
            x + (w/2),
            y + (h/2),
            Graphics.FONT_NUMBER_HOT,
            value,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // TOTAL debajo (sin overlap)
        dc.drawText(
            x + (w/2),
            y + 150,
            Graphics.FONT_MEDIUM,
            "TOTAL",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
}