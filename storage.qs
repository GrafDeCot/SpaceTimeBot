include("building.qs")

class Storage extends Building {
	name() {return "📦Хранилище";}
	icon() {return "📦";}
	description() {return "Обеспечивает хранение 🍍 и ресурсов, если достигнут максимум вместимости, то дальнейшее производство прекращается";}
	capacity(lvl) {
		if (lvl < 9) return (Math.pow(2, lvl)*1000)*this.mult;
		else return Math.floor((Math.sqrt(lvl)*lvl-10))*20000*this.mult;
	}
	capacityProd(lvl) {
		return lvl*10;
	}
	cost() {
		return (this.level*this.level+1)*100;
	}
	info() {
		let msg = this.infoHeader()+"\n";
		msg += `    Вместимость ${food2text(this.capacity(this.level))}, ${this.capacityProd(this.level)}📦\n`;
		msg += `    🛠${this.level+1}:  вместимость ${food2text(this.capacity(this.level+1))}, ${this.capacityProd(this.level+1)}📦 `;
		return msg + this.infoFooter();
	}
	consumption() {return 0;}
}
