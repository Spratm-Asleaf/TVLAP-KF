#include <stdio.h>


int main()
{
    FILE* infile = fopen("Tag 23-21-12.log","r");
    FILE* outfile = fopen("wsx.txt","w");
    double Dist[8];
    double Pos[2];
    int i = 0;
    int id;

    while(!feof(infile))
    {
        printf("%d\n",++i);
        fscanf(infile, "tid:%d Seq:%d %lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\tpos: %lf\t%lf\t", &id, &id, Dist, Dist+1, Dist+2, Dist+3, Dist+4, Dist+5, Dist+6, Dist+7, Pos, Pos+1);
        fprintf(outfile, "%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\n", Dist[0], Dist[1], Dist[2], Dist[3], Dist[4], Dist[5], Dist[6], Dist[7], Pos[0], Pos[1]);
    }

    return 0;
}
