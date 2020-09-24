class Research {
	constructor (name, desc, func, time, cost, locked = false, children = []) {
		this.name = name;
		this.desc = desc;
		this.func = func;
		this.time = time;
		this.cost = cost;
		this.locked = locked;
		this.children = children;
		this.active = false;
	}
	
	start() {
		this.active = true;
	}
	
	step(st) {
		if (this.active) {
			this.time -= st;
			if (this.time <= 0) {
				this.time = 0;
				this.active = false;
				return this.func;
			}
		}
		return undefined;
	}

	unlock(l) {this.locked = !l;}

	load(o) {
		this.active = o.active;
		if (this.locked) this.locked = o.locked;
		if (o.time == 0 || o.active) this.time = o.time;
		for (let i = 0; i < this.children.length; i++) {
			for (let child of o.children) {
				if (this.children[i].name == child.name) {
					this.children[i].load(child);
				}
			}
		}
	}

	add (...children) {
		for (let child of children) {
			this.children.push(child);
		}
		return this;
	}

	addNext (child) {
		this.children.push(child);
		return this.children[this.children.length-1];
	}

	traverse (callback, traversal = Research.Traversal.DepthFirst, depth = 0, prefix = "") {
		traversal.call(this, callback, depth, prefix);
		return this;
	}

	reduce (callback, initial, mode) {
		let acc = initial;
		let depth = 0;
		this.traverse((n, d, p) => {acc = callback(acc, n, d, p)}, mode, depth);
		return acc;
	}

	every (callback) {
		return this.reduce((a, n) => a && callback(n), true);
	}

	some (callback) {
		return this.reduce((a, n) => a || callback(n), false);
	}

	find (callback, mode) {
		return this.reduce((a, n) => a || (callback(n)? n: false), false, mode);
	}

	includes (value) {
		return this.some(n => n.value === value);
	}

}


Research.Traversal = {
	BreadthFirst: function(callback) {
		let nodes = [this];
		while (nodes.length > 0) {
			const current = nodes.shift();
			callback(current);
			nodes = nodes.concat(current.children,  Research.Traversal.BreadthFirst);
		}
	},
	DepthFirst: function(callback, depth = 0, prefix = "") {
		callback(this, depth, prefix);
		if (prefix.length >= 1) {
			if (prefix[prefix.length - 1] == "├") prefix = prefix.slice(0, -1) + "│";
			if (prefix[prefix.length - 1] == "└") prefix = prefix.slice(0, -1) + " ";
		}
		for (let i = 0; i < this.children.length; i++) {
			let pref = prefix;
			if (i == this.children.length-1) pref += " └";
			else pref += " ├"
			this.children[i].traverse(callback, Research.Traversal.DepthFirst, depth+1, pref);
		}
	},
	Actual: function(callback, depth = 0, prefix = "") {
		if (this.time > 0) {
			callback(this, depth, prefix);
		} else {
			let nodes = this.children.filter(v => !v.locked);
			nodes.forEach(n => n.traverse(callback, Research.Traversal.Actual, depth+1));
		}
	}
};


const sienceTree = function(ret, res, depth, prefix) {
	const with_price = false;
	let pref_main = prefix;
	if (with_price)
		if (pref_main.length >= 1)
			pref_main = pref_main.slice(0, -1) + "├";
		
	ret += "<code>" + pref_main;
	ret += res.locked ? "🚫" : (res.time > 0 ? (res.active ? "⏳" : "🔘") : "✅");
	ret += "</code>";
	ret += `${res.name}`;
	ret += '\n';
	if (with_price){
		let pref_price = "<code>" + prefix;
		if (pref_price.length >= 1) {
			if (pref_price[pref_price.length - 1] == "├") pref_price = pref_price.slice(0, -1) + "│";
		} else
			pref_price = " │";
		ret += pref_price + "   ";
		if (depth > 0) ret += "  ";
		ret += "</code>" + `${money2text(res.cost)} ${time2text(res.time)}`;
		ret += '\n';
	}
	return ret;
}

const sienceArray = function(a, r) {
	a.push(r.name);
	return a;
}

const sienceDetail = function(a, r) {
	a += `<b>${r.name}</b> - ${money2text(r.cost)}`
	if (r.active) a += "\n    исследуется, осталось";
	a += ` ${time2text(r.time)}\n`;
	a += `    ${r.desc}\n`;
	return a;
}


function createSienceTree() {
	let s = new Research("🔍🌍Разведка планеты", "Исследует планету на наличие полезных ресурсов, открывает доступ к строительству завода.", "enable_factory", 2000, 25000);
	s.addNext(new Research("🔍🔋Аккумуляторы", "Открывает доступ к строительству аккумуляторов", "enable_accum", 5000, 100000)).
	  addNext(new Research("🔍🔌Экономия энергии 1", "На 10% сокращает потребление электричества", "eco_power", 10000, 500000)).
	  addNext(new Research("🔍🔌Экономия энергии 2", "На 10% сокращает потребление электричества", "eco_power", 20000, 1000000)).
	  addNext(new Research("🔍🔌Экономия энергии 3", "На 10% сокращает потребление электричества", "eco_power", 30000, 2000000)).
	  addNext(new Research("🔍🔌Экономия энергии 4", "На 10% сокращает потребление электричества", "eco_power", 50000, 5000000));
	s.children[0].addNext(new Research("🔍🔋Улучшеные аккумуляторы", "Увеличивает ёмкость аккумуляторов на 20%", "upgrade_accum", 15000, 800000));
	s.children[0].addNext(new Research("🔍🚀Корабли", "Открывет доступ к постройке верфи", "enable_ships", 9000, 400000, true)).
	              addNext(new Research("🔍💸Торговля", "Позволяет покупать/продавать ресурсы", "enable_trading", 12000, 700000));
	s.addNext(new Research("🔍🛠Быстрое строительство", "В 2 раза ускоряет постройку зданий", "fastbuild", 4000, 1000000)).
	  addNext(new Research("🔍🛠Быстрое строительство 2", "На 50% ускоряет постройку зданий", "fastbuild", 10000, 2000000)).
	  addNext(new Research("🔍🛠Быстрое строительство 3", "На 30% ускоряет постройку зданий", "fastbuild", 10000, 4000000));
	return s;
}


