// JavaScript Document
jQuery(document).ready( function() {	
	
	$container = jQuery('#wmle_container');		 // START MASONRY
	$container.imagesLoaded(function(){
		$container.masonry();
	})
								 
	jQuery(".wmle_loadmore_btn").click( function(e) {
		e.preventDefault();
		url 				= jQuery(this).attr("href");
		containerDivId  	= jQuery(this).attr("rel")
		pageNumber 			= jQuery("#"+containerDivId).attr("data-page");
		randSeed 			= jQuery("#"+containerDivId).attr("data-seed");
		jQuery("#"+containerDivId).attr("data-load-status",'no');
		if (pageNumber == null){
		  pageNumber = 1;
		}
		url = url + '&pageNumber=' + pageNumber + '&randSeed=' + randSeed ;
		jQuery.ajax({
			dataType : "json",
			url : url,
			beforeSend : function(){
				jQuery("img.loading_icon").show();
				jQuery('.wmle_loadmore_btn').html('Loading...');
			},
			success: function(response) {
				if(response.status == "ok" || response.status == "no_posts") {
					var newPageNumber = parseInt(pageNumber) + 1;
					var getStartedBox = "";
					var moreExamplesSoon = "";
					var page = "";
					if (pageNumber === 1) {
						page = window.location.pathname.match("/android/") ? "android" : 
            							window.location.pathname.match("/ios/") ? "ios" :
            							window.location.pathname.match("/research-tools/")? "research" : 
								"";
						if (!!page){
							var getStarted = {
								    android: {
								        url: "//dev.choosemuse.com/android/getting-started-with-libmuse-android",
								        img: "//storage.googleapis.com/ix_choosemuse/uploads/dev-site/ic_android_grey_90px.svg",
								        title: "Getting Started with Android",
								        excerpt: "Build your first Muse app in five minutes"
								    },
								    ios: {
								        url: "//dev.choosemuse.com/ios/getting-started-with-libmuse-ios",
								        img: "//storage.googleapis.com/ix_choosemuse/uploads/dev-site/ic_ios_grey_90px.svg",
        								title: "Getting Started with iOS",
       			 						excerpt: "Build your first Muse app in five minutes"
    									},
    								   research: {
        								url: "//dev.choosemuse.com/research-tools/getting-started",
    									img: "//dev.choosemuse.com/wp-content/uploads/2015/04/hit_record.png",
        								title: "Getting Started with Research Tools",
        								excerpt: "Get data from your Muse in minutes"
    								    }
								}


							 getStartedBox = '<div class="wmle_item_holder col3" style="display:none;">' +
							    '<div class="wmle_item">' +
					        	            '<div class="wpme_image">' +
						        	        '<a href="' + getStarted[page].url + '"><img width="300" height="180" src="'
							                + getStarted[page].img +'"></a>' +
							            '</div>' +
						    	            '<div class="wmle_post_meta">' +
        							    '</div>' +
								    '<div class="wmle_post_title">' +
            								'<a href="' + getStarted[page].url + '">'
            								+ getStarted[page].title + '</a>' +
        							    '</div>' +
								    '<div class="wmle_post_excerpt">' +
							            '<p>' + getStarted[page].excerpt + ' […]</p>' +
							        '</div>' +
							    '</div><!-- EOF wmle_item_holder -->' +
							'</div>';

							moreExamplesSoon = '<div class="wmle_item_holder col3" style="display:none;">' +
                                                            '<div class="wmle_item">' +
                                                                    '<div class="wpme_image">' +
                                                                        '<img width="300" height="180" src="//storage.googleapis.com/ix_choosemuse/uploads/dev-site/img_comingsoon_300x350.jpg">' +
                                                                    '</div>' +
                                                                    '<div class="wmle_post_meta">' +
                                                                    '</div>' +
                                                                    '<div class="wmle_post_excerpt">' +
                                                                    '<p></p>' +
                                                                '</div>' +
                                                            '</div><!-- EOF wmle_item_holder -->' +
                                                        '</div>';
						}

					}

					response.elements = response.elements || "";

					$boxes = jQuery( getStartedBox + response.elements + moreExamplesSoon);
					$container.append( $boxes ).imagesLoaded( function(){
						jQuery('.wmle_item_holder').show(); 
						$container.masonry( 'appended', $boxes);
						jQuery("img.loading_icon").hide();
						jQuery("#"+containerDivId).attr("data-page", newPageNumber);
						jQuery('.wmle_loadmore_btn').html('Load More');
						jQuery("#"+containerDivId).attr("data-load-status",'ready');
						if (parseInt(newPageNumber) > parseInt(response.max_pages) || !response.max_pages){ // Hide load more btn if no more pages.
							jQuery('.wmle_loadmore').remove();
						}
					});
					
				}
				else {
				   jQuery('.wmle_loadmore_btn').html(response.message);
				}
			}
		})
	})   
})
