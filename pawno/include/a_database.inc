#if defined _database_included
	#endinput
#endif
#define _database_included

native DB:db_open(const name[]);
native db_close(DB:db);
native DBResult:db_query(DB:db, const query[]);
native db_free_result(DBResult:dbresult);
native db_num_rows(DBResult:dbresult);
native db_next_row(DBResult:dbresult);
native db_num_fields(DBResult:dbresult);
native db_field_name(DBResult:dbresult, field, result[], maxlength = sizeof(result));
native db_get_field(DBResult:dbresult, field, result[], maxlength = sizeof(result));
native db_get_field_assoc(DBResult:dbresult, const field[], result[], maxlength = sizeof(result));
