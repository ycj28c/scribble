---
layout: post
title: HTML Smooth Scroll Header
disqus: y
share: y
categories: [Language]
tags: [Jquery, Javascript]
---

My Thought
----------

This actually very common, when there is big list of HTML table, when user scroll the browser windows, they want table header freeze on the top. This article will use JQuery to implement.

we have a table have below column:
~~~javascript
<thead id='votResHeader'>
 <tr style='height:50px'>
  <th class='header' style='width: 5%;' id='vrNumberTh'><p>#</p></th>
  <th class='header' style='' id='vrProposalTh'><p>PROPOSAL</p></th>
  <th class='header' style='width: 15%;' id='vrTypeTh'><p>TYPE</p></th>
  <th class='header' style='width: 15%;' id='vrProposedByTh'><p>PROPOSED BY</p></th>
  <th class='header' style='width: 8%;' id='vrStatusTh'><p>STATUS</p></th>
  <th class='header' style='width: 8%;' id='vrForTh'><p>FOR</p></th>
  <th class='header' style='width: 8%;' id='vrAgainstTh'><p>AGAINST</p></th>
  <th class='header' style='width: 8%;' id='vrAbstainTh'><p>ABSTAIN</p></th>
 </tr>
</thead>
~~~

First, let's figure out the offset top of the table, the table header id is 'votResHeader', when scroll > then the table body top offset, use fixed position, otherwise back to normal table
~~~javascript
$(window).scroll(function(e) {
	var fixmeTop = $('#votResBody').offset().top;
	// BackToTop Functionality and buttons header freeze
	if ($(this).scrollTop() >= fixmeTop) {  // If page is scrolled more than fixmeTop
		$('#votResHeader').css({ //Freezing header
			'position': 'fixed',
			'top': '0px',
			'margin-top': '0px',
			'padding-top': '0px',
		});
		// sync the table body column width and head column width
		syncVotingResultTableHeadAndBodyWidth();
	} else {
		$('#votResHeader').css({ //Static header
			'position': 'static',
			'margin-top': '0px',
			'padding-top': '40px',
		});
		syncVotingResultTableHeadAndBodyWidth();
	}
});
~~~

However, when table header become fixed, the width of table could mess up because the content width change. To keep table look same as before, we need to set width percentage at <td> in the <tbody> to static the body column width. In addition to that, we need adjust the width of float header for better user experience. There is syncVotingResultTableHeadAndBodyWidth() method in above function, It is the major code to guarantee each table head column stay the same width as body. In fact, it just dynamically force the head width pixel as calculated body column pixel, jQuery is able to do this job.
~~~javascript
syncVotingResultTableHeadAndBodyWidth = function() {
	$('#vrNumberTh').css({
		'width': $('#vrNumberTd').width() + parseInt($('#vrNumberTd').css('padding-right')) + parseInt($('#vrNumberTd').css('padding-left')) + parseInt($('#vrNumberTd').css('borderLeftWidth')) + parseInt($('#vrProposalTd').css('borderRightWidth')),
	});
	$('#vrProposalTh').css({
		'width': $('#vrProposalTd').width() + parseInt($('#vrProposalTd').css('padding-right')) + parseInt($('#vrProposalTd').css('padding-left')) + parseInt($('#vrProposalTd').css('borderLeftWidth')) + parseInt($('#vrProposalTd').css('borderRightWidth')),
	});
	$('#vrTypeTh').css({
		'width': $('#vrTypeTd').width() + parseInt($('#vrTypeTd').css('padding-right'))+parseInt($('#vrTypeTd').css('padding-left')) + parseInt($('#vrTypeTd').css('borderLeftWidth')) + parseInt($('#vrTypeTd').css('borderRightWidth')),
	});
	$('#vrProposedByTh').css({
		'width': $('#vrProposedByTd').width() + parseInt($('#vrProposedByTd').css('padding-right'))+parseInt($('#vrProposedByTd').css('padding-left')) + parseInt($('#vrProposedByTd').css('borderLeftWidth')) + parseInt($('#vrProposedByTd').css('borderRightWidth')),
	});
	$('#vrStatusTh').css({
		'width': $('#vrStatusTd').width() + parseInt($('#vrStatusTd').css('padding-right'))+parseInt($('#vrStatusTd').css('padding-left')) + parseInt($('#vrStatusTd').css('borderLeftWidth')) + parseInt($('#vrStatusTd').css('borderRightWidth')),
	});
	$('#vrForTh').css({
		'width': $('#vrForTd').width() + parseInt($('#vrForTd').css('padding-right'))+parseInt($('#vrForTd').css('padding-left')) + parseInt($('#vrForTd').css('borderLeftWidth')) + parseInt($('#vrForTd').css('borderRightWidth')),
	});
	$('#vrAgainstTh').css({
		'width': $('#vrAgainstTd').width() + parseInt($('#vrAgainstTd').css('padding-right'))+parseInt($('#vrAgainstTd').css('padding-left')) + parseInt($('#vrAgainstTd').css('borderLeftWidth')) + parseInt($('#vrAgainstTd').css('borderRightWidth')),
	});
	$('#vrAbstainTh').css({
		'width': $('#vrAbstainTd').width() + parseInt($('#vrAbstainTd').css('padding-right'))+parseInt($('#vrAbstainTd').css('padding-left')) + parseInt($('#vrAbstainTd').css('borderLeftWidth')) + parseInt($('#vrAbstainTd').css('borderRightWidth')),
	});			
}
~~~

Finally, when we resize the table, will want to do the same thing, add below piece of code:
~~~javascript
$(window).resize(function(e) {
	syncVotingResultTableHeadAndBodyWidth();
});
~~~

Full Example can found [here](https://jsfiddle.net/ycj28c/4gxLdrom/2/), this example also include the tablesort in the freeze head:
[https://jsfiddle.net/ycj28c/4gxLdrom/2/](https://jsfiddle.net/ycj28c/4gxLdrom/2/)

Reference
----------
* [How to get border width in jQuery/javascript](https://stackoverflow.com/questions/3787502/how-to-get-border-width-in-jquery-javascript)
* [tablesort](https://mottie.github.io/tablesorter/docs/)