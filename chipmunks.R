library (rinat)
library (dplyr)

#Bounding box coordinates for the continental US
bounds <- c(24.396308, -124.848974, 48.384358, -66.885444)

chipmunks <- get_inat_obs(taxon_name = "tamias striatus", quality = "research", maxresults = 10000, bounds = bounds  )

usa_chipmunks <- chipmunks %>%
	{filter (. , !grepl("Canada", place_guess) ) }
	

