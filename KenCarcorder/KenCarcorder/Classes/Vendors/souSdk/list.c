//-----------------------------------------------------------------------------
// Author      : 朱红波
// Date        : 2012.01.18
// Version     : V 1.00
// Description : 
//-----------------------------------------------------------------------------
#include "list.h"

//***************************************************************************
//---------------------------------------------------------------------------创建
TList* lst_Init()
{
  TList* lst = (TList*)malloc(sizeof(TList));
  memset(lst, 0, sizeof(TList));
  return lst;
}
//---------------------------------------------------------------------------释放
void lst_Free(TList* lst)
{
  lst_Clear(lst);
}
//---------------------------------------------------------------------------统计数量
int lst_Count(TList* lst)
{
  return lst->FCount;
}
//---------------------------------------------------------------------------增加
int lst_Add(TList* lst, void* Item)
{
  if (lst->FCount >= MaxLstSize) return -1;

  int Result = lst->FCount;
  lst->FList[Result] = Item;
  lst->FCount++;
  return Result;
}
//---------------------------------------------------------------------------清除所有
void lst_Clear(TList* lst)
{
  memset(&lst, 0, sizeof(TList));
}
//---------------------------------------------------------------------------删除
void lst_Delete(TList* lst, int Index)
{
  if ((Index < 0) || (Index >= lst->FCount)) return;
  lst->FCount--;
  if (Index < lst->FCount)
  {
    memcpy(&lst->FList[Index], &lst->FList[Index + 1], (lst->FCount - Index) * sizeof(void*));
  }
}
//---------------------------------------------------------------------------索引
int lst_IndexOf(TList* lst, void* Item)
{
  int Result = 0;

  while ((Result < lst->FCount) && (lst->FList[Result] != Item))
  {
    Result++;
  }
  if (Result == lst->FCount)
    Result = -1;
  return Result;
}

//---------------------------------------------------------------------------插入
void lst_Insert(TList* lst, int Index, void* Item)
{
  if ((Index < 0) || (Index > lst->FCount)) return;

  if (Index < lst->FCount)
  {
    memcpy(&lst->FList[Index + 1], &lst->FList[Index], (lst->FCount - Index) * sizeof(void*));
  }
  lst->FList[Index] = Item;
  lst->FCount++;
}
//---------------------------------------------------------------------------交换
void lst_Exchange(TList* lst, int CurIndex, int NewIndex)
{
  void* tmp = lst->FList[CurIndex];
  lst->FList[CurIndex] = lst->FList[NewIndex];
  lst->FList[NewIndex] = tmp;
}
//---------------------------------------------------------------------------移动
void lst_Move(TList* lst, int CurIndex, int NewIndex)
{
  void* Item;
  if (CurIndex != NewIndex)
  {
    if ((NewIndex < 0) || (NewIndex >= lst->FCount)) return;
    Item = lst->FList[CurIndex];
    lst->FList[CurIndex] = NULL;
    lst_Delete(lst, CurIndex);
    lst_Insert(lst, NewIndex, NULL);
    lst->FList[NewIndex] = Item;
  }
}
//---------------------------------------------------------------------------删除
int lst_Remove(TList* lst, void* Item)
{
  int Result = lst_IndexOf(lst, Item);
  if (Result >= 0)
    lst_Delete(lst, Result);
  return Result;
}

//---------------------------------------------------------------------------序列节点
void* lst_Items(TList* lst, int Index)
{
  if(Index<0) return NULL;
  if(Index>=lst->FCount) return NULL;
  return lst->FList[Index];
}
//-------------------------------------------------------------------------
