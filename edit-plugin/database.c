#include <stdio.h>
#include <string.h>
#include <sqlite3.h>

#define MAX_RESULT_SIZE 1024

static int callback(void *data, int argc, char **argv, char **azColName) {
    char *result = (char*)data;
    int i;
    for (i = 0; i < argc; i++) {
        strcat(result, azColName[i]);
        strcat(result, " = ");
        strcat(result, (argv[i] ? argv[i] : "NULL"));
        strcat(result, "\n");
    }
    strcat(result, "\n");
    return 0;
}

char* execute_query(const char* input) {
    static char result[MAX_RESULT_SIZE];
    sqlite3 *db;
    char *err_msg = 0;
    int rc;

    result[0] = '\0';  // Initialize result string

    char db_path[256];
    const char* query;

    // Split input into db_path and query
    const char* newline = strchr(input, '\n');
    if (newline == NULL) {
        sprintf(result, "Invalid input format\n");
        return result;
    }

    int path_length = newline - input;
    strncpy(db_path, input, path_length);
    db_path[path_length] = '\0';
    query = newline + 1;

    rc = sqlite3_open(db_path, &db);
    if (rc != SQLITE_OK) {
        sprintf(result, "Cannot open database: %s\n", sqlite3_errmsg(db));
        return result;
    }

    rc = sqlite3_exec(db, query, callback, result, &err_msg);

    if (rc != SQLITE_OK) {
        sprintf(result, "SQL error: %s\n", err_msg);
        sqlite3_free(err_msg);
    }

    sqlite3_close(db);

    return result;
}

