include("building.qs")

class Spaceyard extends Building {
	name() {return "🏗Верфь";}
	icon() {return "🏗";}
	description() {return "Открывает возможность строить космические корабли. Чем больше уровень тем больше доступных моделей.";}
	cost() {
		return Math.pow(7, (this.level+7));
	}
	info() {
		let msg = this.infoHeader()+"\n";
		msg += `    🛠${this.level+1}`;
		return msg + this.infoFooter();
	}
	consumption() {return 16;}
	buildTimeAdd() {return 3000;}
	shipsBuildSpeed(l) {return l;}
	buildShip() {
		if (this.ship_que.length > 0) {
			this.ship_bt -= this.shipsBuildSpeed(this.level);
			if (this.ship_bt <= 0) {
				const ret = this.ship_que.shift();
				if (this.ship_que.length > 0)
					this.ship_bt = ShipModels()[this.ship_que[0]].price()*Resources_base;
				return ret;
			}
		}
		return -1;
	}
	queShip(si) {
		this.ship_que.push(si);
		this.ship_bt = ShipModels()[si].price()*Resources_base;
	}
}
