include("building.qs")

class EnergyStorage extends Building {
	name() {return "🔋Аккумуляторы";}
	icon() {return "🔋";}
	description() {return "Обеспечивает хранение излишков ⚡энергии, необходимой для заправки кораблей. Требует ⚡ для работы";}
	capacity(lvl) {
		return (lvl*100);
	}
	cost() {
		return (Math.floor(Math.sqrt((this.level+1)*100)))*1000;
	}
	info() {
		let msg = this.infoHeader();
		msg += `    Вместимость ${this.capacity(this.level)}⚡\n`;
		msg += `    🛠${this.level+1}:  вместимость ${this.capacity(this.level+1)}⚡ `;
		return msg + this.infoFooter();
	}
	consumption() {return 2;}
	buildTimeAdd() {return 1000;}
	add(e) {
		if (this.level > 0) {
			this.acc_cnt += 1;
			if (acc_cnt > 60) {
				this.acc_cnt = 0;
				this.energy += e;
				if (this.energy < 0) this.energy = 0;
				if (this.energy > this.capacity(this.level))
					this.energy = this.capacity(this.level)
			}
		}
	}
}