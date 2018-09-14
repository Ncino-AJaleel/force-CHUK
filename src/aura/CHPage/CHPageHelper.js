({
	nav : function (component) {

		component.find("navService").navigate({
			type: 'standard__recordPage',
			attributes: {
				recordId: component.get("v.recordId"),
				actionName: "view"
			}
		});
	},


})