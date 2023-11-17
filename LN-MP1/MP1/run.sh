#!/bin/bash

mkdir -p compiled images

rm -f ./compiled/*.fst ./images/*.pdf

# ############ Compile source transducers ############

for i in sources/*.txt tests/*.txt; do
	echo "Compiling: $i"
    fstcompile --isymbols=syms.txt --osymbols=syms.txt $i | fstarcsort > compiled/$(basename $i ".txt").fst
done

# ############ CORE OF THE PROJECT  ############

echo -e "\nDoing FST operations..."


#create transducer 2
fstconcat compiled/mmm2mm.fst compiled/accept_rest_of_date.fst > compiled/mix2numerical.fst

#create transducer 3
fstconcat compiled/pt2en_aux.fst compiled/accept_rest_of_date.fst > compiled/pt2en.fst

#create transducer 4
fstinvert compiled/pt2en_aux.fst > compiled/en2pt_aux.fst
fstconcat compiled/en2pt_aux.fst compiled/accept_rest_of_date.fst > compiled/en2pt.fst

#create transducer 8
fstconcat compiled/month.fst compiled/removeslash.fst > compiled/temp1.fst
fstconcat compiled/temp1.fst compiled/day.fst > compiled/temp2.fst
fstconcat compiled/temp2.fst compiled/slashtocomma.fst > compiled/temp3.fst
fstconcat compiled/temp3.fst compiled/year.fst > compiled/datenum2text.fst

#create transducer 9
fstcompose compiled/mix2numerical.fst compiled/datenum2text.fst > compiled/temp4.fst
fstcompose compiled/pt2en.fst compiled/temp4.fst > compiled/temp5.fst
fstunion compiled/temp4.fst compiled/temp5.fst > compiled/mix2text.fst

#create transducer 10
fstunion compiled/mix2text.fst compiled/datenum2text.fst > compiled/date2text.fst



# ############ generate PDFs  ############
echo -e "\nStarting to generate PDFs"
for i in compiled/*.fst; do
	echo "Creating image: images/$(basename $i '.fst').pdf"
   fstdraw --portrait --isymbols=syms.txt --osymbols=syms.txt $i | dot -Tpdf > images/$(basename $i '.fst').pdf
done



# ############      3 different ways of testing     ############
# ############ (you can use the one(s) you prefer)  ############


#1 - generates files
echo -e "\n***********************************************************"
echo "Testing 4 (the output is a transducer: fst and pdf)"
echo "***********************************************************"


for w in compiled/t-*.fst; do
    fstcompose $w compiled/date2text.fst | fstshortestpath | fstproject --project_type=output |
                  fstrmepsilon | fsttopsort > compiled/$(basename $w ".fst")-out.fst
done
for i in compiled/t-*-out.fst; do
	echo "Creating image: images/$(basename $i '.fst').pdf"
   fstdraw --portrait --isymbols=syms.txt --osymbols=syms.txt $i | dot -Tpdf > images/$(basename $i '.fst').pdf
done


#3 - presents the output with the tokens concatenated (uses a different syms on the output)
fst2word() {
    awk '{if(NF>=3){printf("%s",$3)}}END{printf("\n")}' 
}

echo -e "\n***********************************************************"
echo "Testing... (output is a string  using 'syms-out.txt')"
echo "***********************************************************"


#e. Henrique: 05/15/2020 - MAI/15/2020 - MAY/15/2020
#   Afonso:   08/14/2020 - AGO/14/2020 - AUG/14/2020

echo -e "\nTesting mix2numerical.fst"
trans=mix2numerical.fst
for w in MAY/15/2020 AUG/14/2020; do
    res=$(python3 ./scripts/word2fst.py $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
                       fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
                       fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt | fst2word)
    echo "$w = $res"
done

#-------------------------------------------

echo -e "\nTesting en2pt.fst"
trans=en2pt.fst
for w in MAY/15/2020 AUG/14/2020; do
    res=$(python3 ./scripts/word2fst.py $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
                       fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
                       fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt | fst2word)
    echo "$w = $res"
done

#-------------------------------------------------

echo -e "\nTesting datenum2text.fst"
trans=datenum2text.fst
for w in 05/15/2020 08/14/2020; do
    res=$(python3 ./scripts/word2fst.py $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
                       fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
                       fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./scripts/syms-out.txt | fst2word)
    echo "$w = $res"
done

#---------------------------------------------------

echo -e "\nTesting mix2text.fst"
trans=mix2text.fst
for w in MAY/15/2020 MAI/15/2020 AUG/14/2020 AGO/14/2020; do
    res=$(python3 ./scripts/word2fst.py $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
                       fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
                       fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./scripts/syms-out.txt | fst2word)
    echo "$w = $res"
done

#---------------------------------------------------

echo -e "\nTesting date2text.fst"
trans=date2text.fst
for w in 05/15/2020 MAY/15/2020 MAI/15/2020 08/14/2020 AGO/14/2020 AUG/14/2020; do
    res=$(python3 ./scripts/word2fst.py $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
                       fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
                       fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./scripts/syms-out.txt | fst2word)
    echo "$w = $res"
done


#Aditional tests

echo -e "\nTesting date2text.fst"
trans=date2text.fst
for w in 9/09/2001 01/3/2011 02/24/2022 10/01/2099 12/22/2043 OCT/30/2025 DEZ/13/2069 FEV/25/2071 MAR/21/2060 ; do
    res=$(python3 ./scripts/word2fst.py $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
                       fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
                       fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./scripts/syms-out.txt | fst2word)
    echo "$w = $res"
done


echo -e "\nTesting mix2numerical.fst"
trans=mix2numerical.fst
for w in SEP/5/2018; do
    res=$(python3 ./scripts/word2fst.py $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
                       fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
                       fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt | fst2word)
    echo "$w = $res"
done
echo -e "\nThe end"