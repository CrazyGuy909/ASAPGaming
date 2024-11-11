var db = require("./db.js");
var app = require("./methods.js");
var cacheHistory = {};

function generateData(res, price) {
	var date = new Date();
	var newInfo = {
		year: {},
		currentMonth: date.getMonth(),
		month: {},
		currentWeek: getWeekNumber(),
		week: {},
		currentDay: date.getDate(),
		day: {}
	};

	if (res == null) {
		return newInfo;
	}else{
		res.send(JSON.stringify(newInfo));
	}
}

function getWeekNumber() {
	var date = new Date();
	date.setHours(0, 0, 0, 0);
	// Thursday in current week decides the year.
	date.setDate(date.getDate() + 3 - ((date.getDay() + 6) % 7));
	// January 4 is always in week 1.
	var week1 = new Date(date.getFullYear(), 0, 4);
	// Adjust to Thursday in week 1 and count number of weeks from date to week1.
	return (
		1 +
		Math.round(
			((date.getTime() - week1.getTime()) / 86400000 -
				3 +
				((week1.getDay() + 6) % 7)) /
			7
		)
	);
}

function updateHistory(id, price) {
	var date = new Date();

	if (cacheHistory[id] == null){
		console.log("Fetching history prices")
		db.query("SELECT * FROM market_reg WHERE item=" + id, function (
			err,
			query
		) {
			if (query[0]) {
				cacheHistory[id] = JSON.parse(query[0].history);
				cacheHistory[id].mainPrice = query[0].mid
			} else {
				cacheHistory[id] = generateData(null);
			}
			updateHistory(id, price);
		});
		return;
	}

	if (cacheHistory[id].year == null)
		cacheHistory[id].year = [];
	var yearStat = cacheHistory[id].year[date.getMonth()];

	if (yearStat) {
		yearStat.sales = yearStat.sales + 1
		yearStat.price = (yearStat.price + price) / 2
	}else{
		cacheHistory[id].year[date.getMonth()] = {
			price : price,
			sales : 1
		}
	}

	
	if (date.getMonth() != cacheHistory[id].currentMonth){
		cacheHistory[id].month = {}
		cacheHistory[id].currentMonth = date.getMonth();
	}

	if (cacheHistory[id].month == null)
	cacheHistory[id].month = []
	var monthStat = cacheHistory[id].month[date.getDate()];

	if (monthStat) {
		monthStat.sales = monthStat.sales + 1
		monthStat.price = (monthStat.price + price) / 2
	}else{
		cacheHistory[id].month[date.getDate()] = {
			price : price,
			sales : 1
		}
	}

	if (getWeekNumber() != cacheHistory[id].currentWeek){
		cacheHistory[id].week = {}
		cacheHistory[id].currentWeek = getWeekNumber();
	}

	if (cacheHistory[id].week == null)
	cacheHistory[id].week = []
	var weekStat = cacheHistory[id].week[date.getDay()];

	if (weekStat) {
		weekStat.sales = weekStat.sales + 1
		weekStat.price = (weekStat.price + price) / 2
	}else{
		cacheHistory[id].week[date.getDay()] = {
			price : price,
			sales : 1
		}
	}

	if (date.getDate() != cacheHistory[id].currentDay){
		cacheHistory[id].currentDay = date.getDate()
		cacheHistory[id].day = {}
	}

	if (cacheHistory[id].day == null)
	cacheHistory[id].day = []
	var dayStat = cacheHistory[id].day[date.getHours()];

	if (dayStat) {
		dayStat.sales = dayStat.sales + 1
		dayStat.price = (dayStat.price + price) / 2
	}else{
		cacheHistory[id].day[date.getHours()] = {
			price : price,
			sales : 1
		}
	}

	if (cacheHistory[id].mainPrice != null){
		cacheHistory[id].mainPrice = cacheHistory[id].mainPrice + Math.ceil((price - cacheHistory[id].mainPrice) / 4)
	}else{
		cacheHistory[id].mainPrice = price
	}

	console.log("Sold item #" + id + " at $" + cacheHistory[id].mainPrice);
	db.query(
		"INSERT INTO market_reg (item, mid, gap, existence, history) VALUES(" +
		id +
		", " + cacheHistory[id].mainPrice + ", 0, 1, '" +
		JSON.stringify(cacheHistory[id]) +
		"') ON DUPLICATE KEY UPDATE history = '" +
		JSON.stringify(cacheHistory[id]) +
		"', mid= " + cacheHistory[id].mainPrice + ";"
	);
}

function setHistory(id) {
	if (cacheHistory[id]) {
		updateHistory(id, null);
	} else {
		db.query("SELECT history FROM market_reg WHERE item=" + id, function (
			err,
			query
		) {
			if (query[0]) {
				cacheHistory[id] = JSON.parse(query[0].history);
				cacheHistory[id].mainPrice = query[0].mid
				console.log("Price loaded: " + query[0].mid)
			} else {
				cacheHistory[id] = generateData(null, null);
			}
			updateHistory(id, null);
		});
	}
}

module.exports = {
	setHistory : setHistory,
	generateData : generateData,
	updateHistory : updateHistory,
	cacheHistory : cacheHistory
};