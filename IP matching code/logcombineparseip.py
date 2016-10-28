wd="T:/courses/MSiA400/Jobs/job_clicks/"

import os
filelist=os.listdir(wd)
NL=len(filelist)
import re
import csv
import bisect

# read ip2location csv in
with open('IP2LOCATION-LITE-DB9.csv') as csvfile:
	readCSV=csv.reader(csvfile,delimiter=',')
	ip2location_list=list(readCSV)
ipendlist=[int(row[1]) for row in ip2location_list]
maxL=len(ipendlist)
#conn = psycopg2.connect(database="scratch", user="xwang", password="Stap@a4agu-r&the", host="gpdb", port="5432")

#cur = conn.cursor()


# create new table
#cur.execute("CREATE TABLE clickstream.log( clicktime timestamp, job_id text NOT NULL, user_id text NOT NULL, ip text);")

# open each file, parse every line

output = open('z:/clicklog1.csv','w')

for doc in filelist[0:200]:
	print(doc)
	hand = open(wd+doc)
	
	
	lcount=0
	for line in hand:
		if lcount<4:
			lcount=lcount+1
			
			continue
		if len(line)==0:
			continue
		
		datestamp=''
		temp=re.findall('[0-9]+-[0-9]+-[0-9]+',line)
		if len(temp)>0 and len(temp[0])==10:
			datestamp=temp[0]
		
		timestamp=''
		temp=re.findall('[0-9]+:[0-9]+:[0-9]+',line)
		if len(temp)>0 and len(temp[0])==8:
			timestamp=temp[0]
		
		jobid=''
		temp=re.findall('jvguid=([0-9a-z]+)',line)
		if len(temp)>0 and len(temp[0])>=20:
			jobid=temp[0].upper()
			jobid=jobid[0:8]+'-'+jobid[8:12]+'-'+jobid[12:16]+'-'+jobid[16:20]+'-'+jobid[20:32]
		
		userid=''
		temp=re.findall('aguid=([0-9a-z]+)',line)
		if len(temp)>0 and len(temp[0])>=20:
			userid=temp[0]
		
		ipaddress='0'
		ipfirst='0'

		temp=re.findall('[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+',line)
		if len(temp)>0 and len(temp[0])>=7:
			ippart=temp[0].split('.')
			ipaddress=int(ippart[0])*(256**3)+int(ippart[1])*(256**2)+int(ippart[2])*256+int(ippart[3])
			indexip=bisect.bisect_left(ipendlist,ipaddress)
			if indexip==maxL:
				indexip=0
			
			ipfirst=ip2location_list[indexip][0]

		
		if len(datestamp+timestamp+jobid+userid+str(ipaddress))<=20:
			continue
			
		output.write(datestamp+','+timestamp+','+jobid+','+userid+','+str(ipaddress)+','+str(ipfirst)+'\n')
	hand.close()


output.close()
