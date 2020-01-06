#!/usr/bin/python

def makeSin_power(p,powpow): 


	x = linspace(0,pi,180)
	pred = sin(x)**powpow
	pred = pred/max(pred)
	peak = where(pred==1)[0]

	tmp = abs(x-p['u']).min()
	shiftInd = abs(x-p['u']).argmin()

	pred = roll(pred,shiftInd-peak[0]) #direction of shift is opposite from 'wshift' in MATLAB

	# here - the x axis should be derived based on teh p.cCenters, so that each
	# function peaks properly...then go back to just shifting N times over the
	# space, not 180 times...
	resampInd = ceil(float(len(x))/float(len(p['x'])))
	pred = pred[0:-1:int(resampInd)]

	return pred


def load_attributes(attr_file,attr_dir):    

	x=os.path.join(attr_dir,attr_file)
	attr = ColumnData(x, header=True)
	#attr = SampleAttributes(x)
	 return attr

def load_nii(nii_file,mask_file,attr,nii_dir,mask_dir):
	"""load experiment dataset"""

	fds = fmri_dataset(samples=os.path.join(nii_dir,nii_file),
					   targets=attr.targets, chunks=attr.chunks,
					   mask=os.path.join(mask_dir,mask_file))
	return fds


def lag_correction(fds,runTRs,lagTRs):
	"""correct dataset for hemodynamic lag"""

	#split dataset into runs
	nRuns = len(fds)/int(runTRs)
	if int(nRuns) != nRuns:
		print("Error! number of TRs per run must be a factor of total TRs")
		raise SystemExit


	split_fds=[]

	for i in range(nRuns): #split dataset into separate runs
		split_fds.append(fds[i*runTRs:(i+1)*runTRs])

	#do the shift for each run
	for i in range(len(split_fds)):
		split_fds[i].sa.targets[lagTRs:] = (split_fds[i]
			.sa.targets[:-lagTRs]) #need to shift target labels too

		split_fds[i].sa.censor[lagTRs:] = (split_fds[i]
			.sa.censor[:-lagTRs]) #and censor labels

		split_fds[i].sa.trials[lagTRs:] = (split_fds[i]
			.sa.trials[:-lagTRs])

		split_fds[i].sa.chunks[lagTRs:] = (split_fds[i]
			.sa.chunks[:-lagTRs])

		split_fds[i] = split_fds[i][lagTRs:]

	#merge back datasets
	fds=split_fds[0]
	for i in range(1,len(split_fds)):
		fds.append(split_fds[i])

	return fds

if __name__ == "__main__":
	#libraries needed by pymvpa
	import os
	from mvpa2.suite import *
	import fnmatch
	from numpy import *
	from pylab import *

	nOrients = 6;   # number of actual orientations in your study
	nChans = 6;     # number of channels that you want to use as your 'basis set' to model the response in each voxel.

	nTrials = 18;             # number trials per orientation for the simulation (must be evenly divisible by nOrients)
	
		subs=[]
		temp = raw_input("Enter SN: ")
		if temp =='0':
		#subs=['01KIS','02KB','03JYM','06PJH','08CYJ','09KDH','10LHJ','11CYJ','12SJK']
		subs=['WMS']
		else:
			subs.append(temp)
	
	rootDir='./'
	
	for sub in subs:
		SN = sub[0:2]
		attr_file='./'+sub+'_ori_att_run.txt'
		print attr_file
		lags=[2]
		ROIs = ['mask_d.nii','mask_m.nii', 'mask_u.nii']

		print ROIs


		save_path='./results/'
		
		nROIs=1
		roiSave=[]
		for lagging in lags:
			print lagging
	
			for i in ROIs:
				print i
				#===load files===
				attr=load_attributes(attr_file=attr_file,attr_dir=rootDir)
				print "attr_loaded"
				fds=load_nii(nii_file='IEM_BOLD.nii',mask_file=i,attr=attr,nii_dir=rootDir,mask_dir=rootDir)

				print "nii_loaded"

				fds.sa['censor']=attr.censor
				fds.sa['trials']=attr.trials

				nVox = fds.nfeatures         
				print 'Voxel Number Orignial:', nVox

				powpow=6                 # sin power for basis function

				fds.samples = asarray(fds.samples)

				#===lag correction===
				fds=lag_correction(fds=fds,runTRs=360,lagTRs=lagging) #another custom subfunction
				print "lagCorrected"
				print len(fds)
				print fds

				#===censoring===
				fds=fds[fds.sa.censor==1] #remove censored points

				print "censored"
				print len(fds)

				#===detrend===
				#   poly_detrend(fds, polyord=1, chunks_attr='chunks')

			
				#fds=fds[fds.sa.chunks<5] # try with 6 runs

				#===remove 'rest' TRs===
				fds=fds[fds.sa.targets!=0]
				print "target 0 removed"
				print len(fds)



				#===zscore per run===
				zscore(fds) 
				#zscore(fds,chunks_attr='chunks') 
				print "run_zscored"
				print len(fds)


				averager = mean_group_sample(['trials', 'chunks'])
				fds = fds.get_mapped(averager)


				runs = unique(fds.sa.chunks) # find the number of unique runs that we did
				chan = []


				for rr in runs:

					fds_train=fds[fds.sa.chunks!=rr]
					fds_test=fds[fds.sa.chunks==rr]


					### feature selection ###
					clf = LinearCSVMC()
					nfeatures = nVox

					#nfeatures=ceil(nVox/2)
					nfeatures = ceil(nVox*0.75)
								#nfeatures =ceil(nVox*0.8)
					fsel = SensitivityBasedFeatureSelection(OneWayAnova(),
							FixedNElementTailSelector(nfeatures, tail='upper', 
							mode='select',sort=False)) 
					# check calsification  
		

					fclf = FeatureSelectionClassifier(clf,fsel)
					fclf.train(fds_train)
					fds_train=fclf.mapper.forward(fds_train)
					fds_test=fclf.mapper.forward(fds_test)	    		
					### end of feature selection ###




					#averager = mean_group_sample(['trials']) 
					averager = mean_group_sample(['targets','chunks']) 
					fds_train = fds_train.get_mapped(averager)
					fds_test = fds_test.get_mapped(averager)




					g_train = fds_train.sa.targets  
					g_train=g_train.astype(float)
					scan_train = fds_train.sa.chunks
					scan_train=scan_train.astype(float)

					g_test = fds_test.sa.targets    
					g_test=g_test.astype(float)
					scan_test = fds_test.sa.chunks
					scan_test=scan_test.astype(float)

					data_train = fds_train.samples;   # alloc a matrix for storing data
					temp=data_train[:]
					temp_chunks=fds_train.chunks

					cnt=0
					for thisChunk in unique(temp_chunks):	
						this_temp=(temp[temp_chunks==thisChunk,:])
						this_temp=this_temp.T	
						m=mean(this_temp,axis=1)
						m_norm=norm(m)
						m_hat=m/m_norm
						m_hat=reshape(m_hat,[len(m_hat),1]) #explicitly define as column vector
						this_temp=this_temp-dot(m_hat,dot(m_hat.T,this_temp))

						if cnt==0:
							temp_new=this_temp
						else:
							temp_new=hstack([temp_new,this_temp])

						cnt=cnt+1

					data_train=temp_new[:].T
					data_train=data_train+100

					data_test = fds_test.samples;   # alloc a matrix for storing data
					temp=data_test[:]
					temp_chunks=fds_test.chunks

					cnt=0
					for thisChunk in unique(temp_chunks):	
						this_temp=(temp[temp_chunks==thisChunk,:])
						this_temp=this_temp.T	
						m=mean(this_temp,axis=1)
						m_norm=norm(m)
						m_hat=m/m_norm
						m_hat=reshape(m_hat,[len(m_hat),1]) #explicitly define as column vector
						this_temp=this_temp-dot(m_hat,dot(m_hat.T,this_temp))

						if cnt==0:
							temp_new=this_temp
						else:
							temp_new=hstack([temp_new,this_temp])

						cnt=cnt+1

					data_test=temp_new[:].T
					data_test=data_test+100

					# set up params of the basis function that will govern response of the voxel
					p={}
					p['x'] = linspace(0, pi-pi/(nOrients), nOrients);  # x-axis to eval the gauss

					print "Computing iteration {0} out of {1}\n".format(rr, shape(runs)[0])

					trn = data_train        # data from training scans (all but one scan)
					tst = data_test         # data from test scan (held out scan)

					trns = scan_train            # vector of scan labels for traning data

					trng = g_train             # vector of trial labels for training data.
					tstg = g_test             # trial labels for tst data.

					uRuns = unique(trns)
					tmp = zeros([nOrients*len(uRuns), shape(trn)[1]])
					sCnt = 1
					for ss in uRuns:
						for ii in arange(nOrients)+1 :
							tmp[sCnt*nOrients-nOrients+ii-1,:] = nanmean(trn[logical_and(trns==ss,trng==ii),:],0)
					#	tmp2 = trna[logical_and(trns==ss,trng==ii)]

						sCnt = sCnt + 1
					trn = tmp

					p['x'] = linspace(0, pi-pi/(nOrients), nOrients);
					p['cCenters'] = linspace(0, pi-pi/(nChans), nChans);
					X = zeros([shape(trn)[0], nChans])

					for ii in arange(nChans):
						p['u'] = p['cCenters'][ii]
						X[:,ii] = tile(makeSin_power(p,powpow), [1,shape(trn)[0]/nOrients]); 

					trn[isnan(trn)]=0
					X[isnan(X)]=0
					w = dot(dot(linalg.inv(dot(X.T,X)),X.T),trn) 

					x = dot(dot(linalg.inv(dot(w,w.T)),w),tst.T) 
					x = x.T

					if rr==1:
						chan = x
						g = g_test
					else:
						chan = vstack([chan,x])
						g = hstack([g,g_test])

				result_each_unshift=zeros([6,6])
				for k in arange(6):
					result_each_unshift[k,:]=mean(chan[g==(k+1)],axis=0)		

				# then shift the rows-data so that the channel corresponding to the stimulus on
				# each trial is in the middle column
				for ii in range(shape(chan)[0]):
					chan[ii,:] = roll(chan[ii,:], int(ceil(nChans/2)-g[ii]))
				#again, python "roll" is opp direction from matlab "wshift"

				result_each_shift=zeros([6,6])
				#for k in arange(6):
					#result_each_shift[k,:]=mean(chan[g==(k+1)],axis=0)

					#plot(mean(chan[g==1,:],axis=0),'b') #0
					#hold('on')
					#plot(mean(chan[g==2,:],axis=0),'g') #30
					#hold('on')
					#plot(mean(chan[g==3,:],axis=0),'r') #60
					#hold('on')
					#plot(mean(chan[g==4,:],axis=0),'c') #90
					#hold('on')
					#plot(mean(chan[g==5,:],axis=0),'m') #120
					#hold('on')
					#plot(mean(chan[g==6,:],axis=0),'y') #150
					#hold('on')
					#plot(mean(chan[g==7,:],axis=0),'k') #150
					#hold('on')
					#plot(mean(chan[g==8,:],axis=0),'p') #150

					#hold('on')
					#show()

					#raw_input("Press Enter to continue")
					#close()

					#plot(mean(chan,axis=0))
					#show()

					#raw_input("Press Enter to continue")
					#close()


				if nROIs==1:
				#channel_responses=mean(chan,axis=0)
					channel_responses_each_unshift=result_each_unshift
					channel_responses_each_shift=result_each_shift
				else:
				#channel_responses=vstack([channel_responses, mean(chan,axis=0)])
					channel_responses_each_unshift=vstack([channel_responses_each_unshift, result_each_unshift])
					channel_responses_each_shift=vstack([channel_responses_each_shift, result_each_shift])

				nROIs=nROIs+1

			#savetxt(SName+'_result.txt',channel_responses,'%f','\t')
			print "********************************************************"
			print SN
			print "done"
			print "********************************************************"
			savetxt(save_path+SN+'_'+str(lagging)+'_BOLD_unshift.txt',channel_responses_each_unshift,'%f','\t')
			

