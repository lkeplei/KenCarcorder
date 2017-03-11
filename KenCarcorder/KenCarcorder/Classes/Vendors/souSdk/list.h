//-----------------------------------------------------------------------------
// Author      : 朱红波
// Date        : 2012.01.18
// Version     : V 1.00
// Description : 
//-----------------------------------------------------------------------------
#ifndef TList_H
#define TList_H

#include "cm_types.h"

#define MaxLstSize 1000
typedef struct TList {
  void* FList[MaxLstSize];
  int FCount; //统计数量，不能修改
}TList;

TList* lst_Init();
void lst_Free(TList* lst);
int lst_Add(TList* lst, void* Item);
void lst_Clear(TList* lst);
void lst_Delete(TList* lst, int Index);
int lst_IndexOf(TList* lst, void* Item);
void lst_Insert(TList* lst, int Index, void* Item);    
void lst_Move(TList* lst, int CurIndex, int NewIndex);
void lst_Exchange(TList* lst, int CurIndex, int NewIndex);
int lst_Remove(TList* lst, void* Item);
void* lst_Items(TList* lst, int Index);
int lst_Count(TList* lst);


//***************************************************************************

#endif

