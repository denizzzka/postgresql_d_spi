/// Server Programming Interface public declarations
module binding.spi;

//~ #include "commands/trigger.h"
//~ #include "lib/ilist.h"
//~ #include "nodes/parsenodes.h"
//~ #include "utils/portal.h"
import core.stdc.config;
import derelict.pq.pq: Oid;

//~ alias uint64 = ulong;

extern(System) nothrow @nogc:

struct SPITupleTable;

/** Plans are opaque structs for standard users of SPI */
alias SPIPlanPtr = size_t*;
alias Datum = size_t*; //FIXME: change it to actual Datum
alias ParamListInfo = size_t*; //FIXME: ditto
alias ParserSetupHook = void function(ParseState* pstate, void* arg); // nodes/params.h:
struct ParseState; // parser/parse_node.h
alias Snapshot = size_t*; // utils/snapshot.h
alias HeapTuple = size_t*; // access/htup.h
alias TupleDesc = size_t*; // access/tupdesc.h
alias Relation = size_t*; // utils/relcache.h
alias Size = size_t; // include/c.h
alias Portal = size_t*; // utils/portal.h

enum SpiStatus
{
    SPI_ERROR_CONNECT =     -1,
    SPI_ERROR_COPY =        -2,
    SPI_ERROR_OPUNKNOWN =   -3,
    SPI_ERROR_UNCONNECTED = -4,
    SPI_ERROR_CURSOR =      -5, /** not used anymore */
    SPI_ERROR_ARGUMENT =    -6,
    SPI_ERROR_PARAM =       -7,
    SPI_ERROR_TRANSACTION = -8,
    SPI_ERROR_NOATTRIBUTE = -9,
    SPI_ERROR_NOOUTFUNC =   -10,
    SPI_ERROR_TYPUNKNOWN =  -11,
    SPI_ERROR_REL_DUPLICATE=-12,
    SPI_ERROR_REL_NOT_FOUND=-13,

    SPI_OK_CONNECT =        1,
    SPI_OK_FINISH =         2,
    SPI_OK_FETCH =          3,
    SPI_OK_UTILITY =        4,
    SPI_OK_SELECT =         5,
    SPI_OK_SELINTO =        6,
    SPI_OK_INSERT =         7,
    SPI_OK_DELETE =         8,
    SPI_OK_UPDATE =         9,
    SPI_OK_CURSOR =         10,
    SPI_OK_INSERT_RETURNING=11,
    SPI_OK_DELETE_RETURNING=12,
    SPI_OK_UPDATE_RETURNING=13,
    SPI_OK_REWRITTEN =      14,
    SPI_OK_REL_REGISTER =   15,
    SPI_OK_REL_UNREGISTER = 16,
    SPI_OK_TD_REGISTER =    17,
}

/* These used to be functions, now just no-ops for backwards compatibility */
//~ #define SPI_push()  ((void) 0)
//~ #define SPI_pop()   ((void) 0)
//~ #define SPI_push_conditional()  false
//~ #define SPI_pop_conditional(pushed) ((void) 0)
//~ #define SPI_restore_connection()    ((void) 0)

//~ extern PGDLLIMPORT uint64 SPI_processed;
//~ extern PGDLLIMPORT Oid SPI_lastoid;
//~ extern PGDLLIMPORT SPITupleTable *SPI_tuptable;
//~ extern PGDLLIMPORT int SPI_result;

int SPI_connect();

int SPI_finish();

int SPI_execute(const(char)* src, bool read_only, c_long tcount);

int SPI_execute_plan(SPIPlanPtr plan, Datum* Values, const(char)* Nulls,
    bool read_only, c_long tcount);

int SPI_execute_plan_with_paramlist(SPIPlanPtr plan,
                                ParamListInfo params,
                                bool read_only, c_long tcount);

int SPI_exec(const(char)* src, c_long tcount);

int SPI_execp(SPIPlanPtr plan, Datum* Values, const(char)* Nulls,
          c_long tcount);

int SPI_execute_snapshot(SPIPlanPtr plan,
                     Datum* Values, const(char)* Nulls,
                     Snapshot snapshot,
                     Snapshot crosscheck_snapshot,
                     bool read_only, bool fire_triggers, c_long tcount);

int SPI_execute_with_args(const(char)* src,
                      int nargs, Oid* argtypes,
                      Datum* Values, const(char)* Nulls,
                      bool read_only, c_long tcount);

SPIPlanPtr SPI_prepare(const(char)* src, int nargs, Oid* argtypes);

SPIPlanPtr SPI_prepare_cursor(const(char)* src, int nargs, Oid* argtypes,
                   int cursorOptions);

SPIPlanPtr SPI_prepare_params(const(char)* src,
                   ParserSetupHook parserSetup,
                   void* parserSetupArg,
                   int cursorOptions);

int SPI_keepplan(SPIPlanPtr plan);

SPIPlanPtr SPI_saveplan(SPIPlanPtr plan);

int SPI_freeplan(SPIPlanPtr plan);

Oid SPI_getargtypeid(SPIPlanPtr plan, int argIndex);

int SPI_getargcount(SPIPlanPtr plan);

bool SPI_is_cursor_plan(SPIPlanPtr plan);

bool SPI_plan_is_valid(SPIPlanPtr plan);

const(char)* SPI_result_code_string(int code);

//~ extern List *SPI_plan_get_plan_sources(SPIPlanPtr plan);
//~ extern CachedPlan *SPI_plan_get_cached_plan(SPIPlanPtr plan);

//~ extern HeapTuple SPI_copytuple(HeapTuple tuple);
//~ extern HeapTupleHeader SPI_returntuple(HeapTuple tuple, TupleDesc tupdesc);
//~ extern HeapTuple SPI_modifytuple(Relation rel, HeapTuple tuple, int natts,
                //~ int *attnum, Datum *Values, const char *Nulls);

int SPI_fnumber(TupleDesc tupdesc, const(char)* fname);
char* SPI_fname(TupleDesc tupdesc, int fnumber);
char* SPI_getvalue(HeapTuple tuple, TupleDesc tupdesc, int fnumber);
Datum SPI_getbinval(HeapTuple tuple, TupleDesc tupdesc, int fnumber, bool* isnull);
char* SPI_gettype(TupleDesc tupdesc, int fnumber);
Oid SPI_gettypeid(TupleDesc tupdesc, int fnumber);
char* SPI_getrelname(Relation rel);
char* SPI_getnspname(Relation rel);

void* SPI_palloc(Size size);
void* SPI_repalloc(void* pointer, Size size);
void SPI_pfree(void* pointer);
Datum SPI_datumTransfer(Datum value, bool typByVal, int typLen);
void SPI_freetuple(HeapTuple pointer);
void SPI_freetuptable(SPITupleTable* tuptable);

Portal SPI_cursor_open(const(char)* name, SPIPlanPtr plan,
                Datum* Values, const(char)* Nulls, bool read_only);

Portal SPI_cursor_open_with_args(const(char)* name,
                          const(char)* src,
                          int nargs, Oid* argtypes,
                          Datum* Values, const(char)* Nulls,
                          bool read_only, int cursorOptions);

Portal SPI_cursor_open_with_paramlist(const(char)* name, SPIPlanPtr plan,
                               ParamListInfo params, bool read_only);

Portal SPI_cursor_find(const(char)* name);
void SPI_cursor_fetch(Portal portal, bool forward, c_long count);
void SPI_cursor_move(Portal portal, bool forward, c_long count);
void SPI_scroll_cursor_fetch(Portal, FetchDirection direction, c_long count);
void SPI_scroll_cursor_move(Portal, FetchDirection direction, c_long count);
void SPI_cursor_close(Portal portal);

//~ extern int  SPI_register_relation(EphemeralNamedRelation enr);
//~ extern int  SPI_unregister_relation(const char *name);
//~ extern int  SPI_register_trigger_data(TriggerData *tdata);

//~ extern void AtEOXact_SPI(bool isCommit);
//~ extern void AtEOSubXact_SPI(bool isCommit, SubTransactionId mySubid);

enum FetchDirection
{
    FETCH_FORWARD,
    FETCH_BACKWARD,
    FETCH_ABSOLUTE,
    FETCH_RELATIVE
}
