import { createChart } from "lightweight-charts";

const StockChart = {
  chart: null,
  mounted() {
    this.chart = createChart("chart", {
      width: window.innerWidth * 0.6,
      height: window.innerHeight * 0.6,
      rightPriceScale: {
        visible: true,
      },
      leftPriceScale: {
        visible: true,
      },
    });
    const seriesBTC = this.chart.addLineSeries({ priceScaleId: "right" });
    // const seriesLTC = this.chart.addLineSeries({ priceScaleId: "left" });

    seriesBTC.priceScale().applyOptions({
      autoScale: true,
      borderColor: "#71649C",
      scaleMargins: {
        top: 0.7, // highest point of the series will be 70% away from the top
        bottom: 0.2,
      },
      minValue: 0,
      tickSize: 10,
      minTick: 0.1,
      precision: 2,
    });

    this.chart.timeScale().applyOptions({
      borderColor: "#71649C",
      tickMarkTime: 4,
      secondsVisible: true,
    });
    this.chart.timeScale().fitContent();

    this.handleEvent("price_update", (msg) => {
      const [time, curr] = Object.keys(msg);
      const newPriceEvt = {
        time: Date.parse(msg.time) / 1000,
        value: msg[curr],
      };
      seriesBTC.update(newPriceEvt);
      // curr === "bitcoin"
      //   ? seriesBTC.update(newPriceEvt)
      //   : seriesLTC.update(newPriceEvt);
    });
    window.addEventListener("resize", () => {
      this.chart.resize(window.innerWidth * 0.6, window.innerHeight * 0.6);
    });
  },

  destroyed() {
    this.chart.remove();
  },
};

export default StockChart;
