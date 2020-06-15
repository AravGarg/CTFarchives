#include<stdio.h>
#include<unistd.h>
#include<stdlib.h>
#include<string.h>

struct node{
	unsigned long first;
	unsigned long second;
	char *data;
	struct node* lchild;
	struct node* rchild;
	struct node* parent;
	unsigned int colour;
	unsigned int cid;
};

unsigned long *null;
unsigned int cid=0;
struct node* root=NULL;

struct node * create_donation()
{
	struct node* node=(struct node*)malloc(sizeof(struct node));
	node->data=(char *)malloc(0x10);
	node->second=0;
	node->cid=cid++;
	insert_colour(root,node);
	repair_insert(node);
	return update_root(node);
}

struct node * insert_colour(struct node* root, struct node *node)
{
	if(root==NULL)
	{
		root=node;
		node->parent=NULL;
		node->lchild=NULL;
		node->rchild=NULL;
		node->colour=0;
		return node;
	}
	if(node->cid>=root->cid)
	{
		if(root->rchild!=NULL)
			{
				insert_colour(root->rchild,node);
			}
		root->rchild=node;
	}
	else
	{
		if(root->lchild!=NULL)
			{
				insert_colour(root->lchild,node);
			}
		root->lchild=node;
	}
	node->parent=root;
	node->lchild=NULL;
	node->rchild=NULL;
	node->colour=1;
	return node;
}

struct node *sibling(struct node *node)
{
	if(node==NULL||node->parent==NULL)
		{return NULL;}
	if(node==node->parent->lchild)
		{return node->parent->rchild;}
	return node->parent->lchild;
}


struct node * repair_insert(struct node *node)
{
	if(node->parent!=NULL)
		{
			if(node->parent->colour!=0)
				{
					if(sibling())					
				}
		}
}


