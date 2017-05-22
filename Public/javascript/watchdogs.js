$(document).ready(function() {
                  
                  $.tablesorter.addParser({
                                          id : 'getOrderAttr',
                                          is : function(sort){ return false; },
                                          format : function(sort, table, cell, cellIndex){ return $(cell).attr('data-order'); },
                                          type: 'number'
                  });
                  
                  
                  $("table#members").tablesorter({
                                                 sortList:[[2,1]],
                                                 cssAsc: 'sorted asc',
                                                 cssDesc: 'sorted desc',
                                                 headers : { 2 : { sorter : 'getOrderAttr' } }
                                                 });
                                                 
                  $("table#teachers").tablesorter({
                                                 sortList:[[3,0]],
                                                 cssAsc: 'sorted asc',
                                                 cssDesc: 'sorted desc',
                                                 headers : { 3 : { sorter : 'getOrderAttr' } }
                                                 });
                  $( "tr" ).click(function() {
                  		var action = $(this).children().first().attr('action');
                  		action = action.replace("delete", "show");
                  		window.location.href = action;
					});
                  });
