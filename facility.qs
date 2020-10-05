include("building.qs")

class Facility extends Building {
	name() {return "🏢База";}
	icon() {return "🏢";}
	description() {
		let msg  = "Главное строение, открывает доступ к новым возможностям, требует ⚡ для работы, и потребляет 🍍\n";
	 	    msg += "1 ур - доступен сканер планет\n";
	 	    msg += "2 ур - доступна исследовательская лаборатория, сканер планет показывает все ресурсы\n";
	 	    msg += "3 ур - доступно исследование 🚀Корабли, открывающее доступ к постройке верфи\n";
	 	    msg += "4 ур - сканер планет показывает уровни построек\n";
		return msg;
	}
	cost() {
		return Math.pow(10, (this.level+3));
	}
	info() {
		let msg = this.infoHeader();
		msg += `    🛠${this.level+1} (-${food2text(this.eat_food())})`;
		return msg + this.infoFooter();
	}
	consumption() {return 20;}
	buildTimeAdd() {return 100;}
	eat_food() {return this.taxes*this.level;}
}
