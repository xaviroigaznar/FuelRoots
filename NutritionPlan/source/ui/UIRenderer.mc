module UI {

    using Toybox.Graphics;

    class UIRenderer {

        function initialize() {
        }

        function drawMetricBox(dc, x, y, w, h, color, title, value, subValue) {

            // Background
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
            dc.fillRectangle(x, y, w, h);

            // Border
            dc.setColor(color, Graphics.COLOR_BLACK);
            dc.drawRectangle(x, y, w, h);

            // Header
            dc.setColor(Graphics.COLOR_WHITE, color);
            dc.fillRectangle(x, y, w, 24);

            dc.drawText(
                x + 10,
                y + 2,
                Graphics.FONT_SMALL,
                title,
                Graphics.TEXT_JUSTIFY_LEFT
            );

            // Main value
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

            dc.drawText(
                w / 2,
                y + (h / 2),
                Graphics.FONT_NUMBER_MEDIUM,
                value,
                Graphics.TEXT_JUSTIFY_CENTER
            );

            // Optional sub value
            if (subValue != null && subValue != "") {

                dc.drawText(
                    w / 2,
                    y + (h / 2) + 25,
                    Graphics.FONT_SMALL,
                    subValue,
                    Graphics.TEXT_JUSTIFY_CENTER
                );
            }
        }

        function drawBottomBox(dc, x, y, w, h, color, title, value) {

            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
            dc.fillRectangle(x, y, w, h);

            dc.setColor(color, Graphics.COLOR_BLACK);
            dc.drawRectangle(x, y, w, h);

            dc.setColor(Graphics.COLOR_WHITE, color);
            dc.fillRectangle(x, y, w, 24);

            dc.drawText(
                x + 10,
                y + 2,
                Graphics.FONT_SMALL,
                title,
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

            dc.drawText(
                w / 2,
                y + (h / 2),
                Graphics.FONT_NUMBER_HOT,
                value,
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }
    }
}