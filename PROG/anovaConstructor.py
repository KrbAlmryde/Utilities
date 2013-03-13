'''
This python code was used to assist in constructing the anova in the function
group_ANOVA. It has been left here for documentation as well as practicality
'''

for blevel in range(1,15):
    for alevel in range(1,4):
        print '-dset', alevel, blevel,
        if alevel == 1:
            print "${listen_array[" + str(blevel-1) + "]}'[1]' \\"
        elif alevel == 2:
            print "${response_array[" + str(blevel-1) + "]}'[1]' \\"
        else:
            print "${control_array[" + str(blevel-1) + "]}'[1]' \\"

