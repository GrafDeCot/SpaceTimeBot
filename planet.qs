include("mininig.qs")
include("resources.qs")
include("spaceyard.qs")
include("solar.qs")
include("factory.qs")
include("research.qs")
include("storage.qs")
include("facility.qs")
include("farm.qs")
include("energystorage.qs")

// Планета
class Planet {
	constructor(id){
		this.money = 0;
		this.food = 200;
		for(let i=0; i<Resources.length; i++)
			this[Resources[i].name] = 0;
		this.farm = new Farm(id);
		this.storage = new Storage(id);
		this.facility = new Facility(id);
		this.solar = new Solar(id);
		this.accum = new EnergyStorage(id);
		this.accum.locked = true;
		this.factory = new Factory(id);
		this.factory.locked = true;
		this.spaceyard = new Spaceyard(id);
		this.spaceyard.locked = true;
		this.chat_id = id;
		this.build_speed = 1;
		this.sience_speed = 1;
		this.energy_eco = 1;
		this.sience = createSienceTree();
		this.factory.type = getRandom(2);
		this.factory.prod_cnt = 0;
		this.accum.energy = 0;
		this.accum.upgrade = 1;
		this.facility.taxes = 1;
		this.trading = false;
		this.storage.mult = 1;
		if (!isProduction) {
			//this.money = 9999999;
			//this.food = 9999999;
			//this.farm.level = 30;
			//this.solar.level = 30;
			//this.storage.level = 30;
			//this.facility.level = 3;
			this.build_speed = 100;
			this.sience_speed = 200;
		}
	}
	getBuildings() {
		let a = [this.facility, this.farm, this.storage, this.solar];
		if (!this.accum.locked) a.push(this.accum);
		if (!this.factory.locked) a.push(this.factory);
		if (!this.spaceyard.locked) a.push(this.spaceyard);
		return a;
	}
	load(o) {
		for (const [key, value] of Object.entries(o)) {
			if (typeof value == 'object') {
				if (this[key]) this[key].load(value);
			} else {
				this[key] = value;
			}
		}
	}
	infoResources(all = true) {
		let msg  = `Деньги: ${money2text(this.money)}\n`;
		    msg += `Еда: ${food2text(this.food)} (+${food2text(this.farm.level + this.facility.taxes * this.facility.level)})\n`;
		    msg += `Энергия: ${this.energy(2)}/${this.energy(1)}⚡\n`;
		if (this.accum.level > 0)
			msg += `Аккум.: ${Math.floor(this.accum.energy)}/${this.accum.capacity(this.accum.level)}🔋 (+${Math.round(this.energy())}🔋 за 100⏳)\n`
		if (all) {
			for(let i=0; i<Resources.length; i++)
				msg += getResourceInfo(i, this[Resources[i].name]) + '\n';
			msg += `Склад: ${this.totalResources()}/${this.storage.capacityProd(this.storage.level)}📦\n`
		}
		return msg;
	}
	totalResources() {
		let total_res = 0;
		for(let i=0; i<Resources.length; i++) total_res += this[Resources[i].name];
		return total_res;
	}
	buyFood(cnt) {
		if (this.money < cnt/100) {Telegram.send(this.chat_id, `Недостаточно 💰`); return;}
		if (this.storage.capacity(this.storage.level) < (this.food+cnt)) {Telegram.send(this.chat_id, "Не хватает места в хранилище📦"); return;}
		this.food += cnt;
		this.money -= cnt/100;
	}
	info() { // отобразить текущее состояние планеты
		let msg = this.infoResources();
		let bds = this.getBuildings();
		for (var value of bds) {
			msg += value.info();
		}
		Telegram.send(this.chat_id, msg);
	}
	step() { // эта функция вызывается каждый timerDone
		this.farm.step(this.build_speed);
		this.storage.step(this.build_speed);
		this.solar.step(this.build_speed);
		this.facility.step(this.build_speed);
		this.factory.step(this.build_speed);
		this.accum.step(this.build_speed);
		this.spaceyard.step(this.build_speed);
		this.accum.add(this.energy());
		if (this.food < this.storage.capacity(this.storage.level)) {
			this.food += this.farm.level - this.facility.taxes * this.facility.level;
			if (this.food > this.storage.capacity(this.storage.level)) {
				this.food = this.storage.capacity(this.storage.level);
				Telegram.send(this.chat_id, "Хранилище заполнено");
			}
		}
		if (this.totalResources() < this.storage.capacityProd(this.storage.level))
			this[Resources[this.factory.type].name] += this.factory.product();
		else {
			this[Resources[this.factory.type].name] -= this.totalResources() - this.storage.capacityProd(this.storage.level);
			if (this[Resources[this.factory.type].name] < 0) this[Resources[this.factory.type].name] = 0;
		}
		let rs_done = this.sience.reduce((a,r) => {
			let x = r.step(this.sience_speed);
			if (x) a = x;
			return a;
		});
		if (rs_done) {
			this[rs_done]();
			Telegram.send(this.chat_id, "Исследование завершено");
		}
	}
	isBuilding() {
		let bds = this.getBuildings();
		for (var value of bds) {
			if (value.isBuilding()) return true;
		}
		return false;
	}
	energy(status) {
		let ep = 0;
		let em = 0;
		let bds = this.getBuildings();
		for (var value of bds) {
			let l = value.level;
			if (value.isBuilding() && value.consumption() > 0) l += 1;
			if (value.consumption()*l > 0)
				em += value.consumption()*l;
			if (value.consumption()*l < 0)
				ep -= value.consumption()*l;
		}
		em = em * this.energy_eco;
		if (status == 1) return Math.floor(ep);
		if (status == 2) return Math.floor(em);
		return (ep - em);
	}
	sienceInfo() {
		return this.sience.reduce(sienceTree, "Исследования:\n");
	}
	sienceList() {
		return this.sience.reduce(sienceArray, [], Research.Traversal.Actual);
	}
	sienceListExt() {
		return this.sience.reduce(sienceDetail, "", Research.Traversal.Actual);
	}
	sienceStart(s) {
		if (this.sience.some(r => r.active)) {
			Telegram.send(this.chat_id, "Сейчас нельзя, исследование уже идёт");
			return;
		}
		let m = this.food;
		m = this.sience.reduce((a,r) => {
			if (r.name == s) {
				a -= r.cost;
				if (a >= 0) {
					r.start();
				}
			}
			return a;
		}, m);
		if (m >= 0 && m < this.food) {
			this.food = m;
			Telegram.send(this.chat_id, "Исследование началось");
		} else {
			Telegram.send(this.chat_id, "Недостаточно денег");
		}
	}
	checkSience() {
		let b1 = (this.facility.level >= 3);
		this.sience.traverse(r => {
			if (r.name == "🔍🚀Корабли") r.unlock(b1);
		});
	}
	fixSience() {
		//this.factory.type = getRandom(2);
		//this.energy_eco = 1;
		//this.food += 750000;
//		this.sience.traverse(r => {
//			if (r.name == "🔍🔌Экономия энергии 1") 
//				if (r.time == 0) this.eco_power();
//		});
	}
	enable_factory() {
		Telegram.send(this.chat_id, "Поздравляем теперь ты можешь построить завод по производству ресурса - "
			 + Resources[this.factory.type].icon + Resources[this.factory.type].desc);
		this.factory.locked = false;
	}
	enable_accum() {
		this.accum.locked = false;
	}
	eco_power() {
		this.energy_eco *= 0.9;
	}
	fastbuild() {
		this.build_speed += 1;
	}
	enable_ships() {
		this.spaceyard.locked = false;
	}
	upgrade_accum() {
		this.accum.upgrade *= 1.2;
	}
	enable_trading() {
		this.trading = true;
	}
	more_taxes() {
		this.facility.taxes *= 2;
	}
	upgrade_capacity() {
		this.storage.mult *= 2;
	}
	miningGame(n) {
		if (n) {
			this.miningame = new MiningGame();
		}
		return this.miningame;
	}
}
