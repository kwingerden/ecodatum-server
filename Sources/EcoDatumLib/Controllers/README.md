Make Resource Actions
=====================

Action	      Method	Path	Note
======        ======  ====  ====
index	        GET	    /users	        Returns all users, optionally filtered by the request data.
store	        POST	  /users	        Creates a new user from the request data.
show	        GET	    /users/:id	    Returns the user with the ID supplied in the path.
replace	      PUT	    /users/:id	    Updates the specified user, setting any fields not present in the request data to nil.
update	      PATCH	  /users/:id	    Updates the specified user, only modifying fields present in the request data.
destroy	      DELETE	/users/:id	    Deletes the specified user.
clear	        DELETE	/users	        Deletes all users, optionally filtered by the request data.
create	      GET	    /users/create	  Displays a form for creating a new user.
edit	        GET	    /users/:id/edit	Displays a form for editing the specified user.
aboutItem	    OPTIONS	/users/:id	    Meta action. Displays information about which actions are supported.
aboutMultiple	OPTIONS	/users	        Meta action. Displays information about which actions are supported.