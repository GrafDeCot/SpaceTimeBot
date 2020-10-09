const Resources  = [{
	name : "resource1",
	desc : "Композиты",
	icon : "🧱",
}, {
	name : "resource2",
	desc : "Механизмы",
	icon : "⚙️"
}, {
	name : "resource3",
	desc : "Реагенты",
	icon : "🛢"
}];

function getResourceInfo(r, c) {
	return Resources[r].desc + `: ${c}` + Resources[r].icon;
}

function getResourceCount(r, c) {
	return `${c}` + Resources[r].icon;
}

for(let Resources_index=0; Resources_index<Resources.length; Resources_index++) Resources[Resources_index].index = Resources_index;

function createResourcesIcons() {
	let arr = [];
	for(let i=0; i<Resources.length; i++) arr.push(Resources[i].icon);
	return arr;
}

function createResourcesDesc() {
	let arr = [];
	for(let i=0; i<Resources.length; i++) arr.push(Resources[i].icon + Resources[i].desc);
	return arr;
}

const Resources_icons = createResourcesIcons();
const Resources_desc = createResourcesDesc();
