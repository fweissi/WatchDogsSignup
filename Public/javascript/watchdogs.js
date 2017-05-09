$(document).ready(function() {
                  
                  $.tablesorter.addParser({
                                          id : 'getOrderAttr',
                                          is : function(sort){ return false; },
                                          format : function(sort, table, cell, cellIndex){ return $(cell).attr('data-order'); },
                                          type: 'number'
                  });
                  
                  
                  $("table#members").tablesorter({
                                                 sortList:[[1,0]],
                                                 cssAsc: 'sorted asc',
                                                 cssDesc: 'sorted desc',
                                                 headers : { 2 : { sorter : 'getOrderAttr' } }
                                                 });
                  })
