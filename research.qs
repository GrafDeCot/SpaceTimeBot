class Research {
	constructor (name, func, time, cost, children = [], locked = false) {
		this.name = name;
		this.locked = locked;
		this.func = func;
		this.children = children;
		this.time = time;
		this.cost = cost;
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

	clone () {
		let that = Object.assign(new Research(), this);
		that.children = this.children.map(n => n.clone());
		return that;
	}

	load(o) {
		for (const [key, value] of Object.entries(o)) {
			//print(key, value);
			if (key == 'children') {
				for (let i = 0; i < this.children.length; i++) {
					for (let child of value) {
						if (this.children[i].name == child.name) {
							this.children[i].load(child);
						}
					}
				}
			} else {
				this[key] = value;
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

  traverse (callback, traversal = Research.Traversal.DepthFirst, depth = 0, index = 0, count = 1, prefix = "") {
    traversal.call(this, callback, depth, index, count, prefix);
    return this;
  }

  reduce (callback, initial, mode) {
    let acc = initial;
    let depth = 0;
    this.traverse((n, d, i, c, p) => {acc = callback(acc, n, d, i, c, p)}, mode, depth);
    //print("reduce->", acc);
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
    DepthFirst: function(callback, depth = 0, index = 0, count = 1, prefix = "") {
        callback(this, depth, index, count, prefix);
    	let nd = depth+1;
    	if (prefix.length >= 1) {
    		if (prefix[prefix.length - 1] == "├") prefix = prefix.slice(0, -1) + "│";
    		if (prefix[prefix.length - 1] == "└") prefix = prefix.slice(0, -1) + " ";
    	}
        for (let i = 0; i < this.children.length; i++) {
    		let pref = prefix;
    		if (i == this.children.length-1) pref += " └";
    		else pref += " ├"
        	this.children[i].traverse(callback, Research.Traversal.DepthFirst, nd, i, this.children.length, pref);
        }
    },
    Actual: function(callback, depth = 0, index = 0, count = 1, prefix = "") {
        if (this.time > 0) {
            callback(this, depth, index, count, prefix);
        } else {
            let nodes = this.children.filter(v => !v.locked);
	        for (let i = 0; i < nodes.length; i++) {
	    		let pref = prefix;
	    		if (i == nodes.length-1) pref += " └";
	    		else pref += " ├"
	        	nodes[i].traverse(callback, Research.Traversal.DepthFirst, nd, i, nodes.length, pref);
	        }
            nodes.forEach(n => n.traverse(callback, Research.Traversal.Actual, depth+1));
        }
    }
};


const sienceTree = function(ret, res, depth, index, count, prefix) {
	const with_price = false;
	let pref_main = prefix;
	if (with_price)
		if (pref_main.length >= 1)
			pref_main = pref_main.slice(0, -1) + "├";
		
	ret += pref_main;
	ret += "[";
	ret += res.locked ? "▒" : (res.time > 0  ? " " : "▇");
	ret += "]";
	ret += `${res.name}`;
	ret += '\n';
	if (with_price){
		let pref_price = prefix;
		if (pref_price.length >= 1) {
			if (pref_price[pref_price.length - 1] == "├") pref_price = pref_price.slice(0, -1) + "│";
		} else
			pref_price = " │";
		ret += pref_price + "   ";
		if (depth > 0) ret += "  ";
		ret += `${res.cost}💰 ${res.time}⏳`;
		ret += '\n';
	}
	return ret;
}

const sienceArray = function(a, r) {
	a.push(r.name);
	return a;
}

function createSienceTree() {
	let s = new Research("🌍Разведка планеты", "survey", 10, 250000);
	s.addNext(new Research("🔋Аккумуляторы", "accum", 50, 1000000)).addNext(new Research("🔌Экономия энергии", "eco_power", 100, 2000000));
	s.addNext(new Research("🛠Быстрое строительство", "fastbuild", 40, 3000000));
	s.addNext(new Research("🚀Корабли", "enable_ships", 20, 400000)).addNext(new Research("💸Торговля", "eco_power", 60, 700000));
	return s;
}

