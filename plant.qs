// Шахта
class Plant extends Building {
	name() {
		return "⛏Шахта";
	}
	cost() {
		return (this.level*this.level*this.level*20 + 100);
	}
	info() {
		let msg = this.infoHeader();
		msg += `    Доход +${this.level}💰\n`;
		msg += `    След. ур. ${this.level+1}:  доход +${this.level+1}💰 `;
		return msg + this.infoFooter();
	}
}
