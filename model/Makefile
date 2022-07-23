MODEL=edhoc_model_draft20200301.pv
TEST=libTest.pv
LIB=edhoc_common.pvl

SRC=edhocM4.spthy
TAMARIN_CLEAN=tamarin-prover
TAMARIN=${TAMARIN_CLEAN} --quit-on-warning --heuristic=O --oraclename=oracle.py
PROOFS=proofs


# Set this to PASSIVE for passive attacker; else the attacker is DY
#MATTACKER=-Dm4ATTACKER=PASSIVE
MATTACKER=-Dm4ATTACKER=ACTIVE

# Set this switch to include AD_3 in the model
MAD3=-Dm4AD3

# All flags that are required for all models
MFLAGS=${MATTACKER} ${MAD3}

# Flags and filenames used for each method-model
METHODPAIRS=PSK_PSK SIG_SIG SIG_STAT STAT_SIG STAT_STAT
METHODSINGLES=PSK SIG STAT

MSIGSIG=-Dm4METHODI=SIG -Dm4METHODR=SIG
SIGSIG=edhoc_SIG_SIG.spthy
TSIGSIG=TMP_${SIGSIG}
MSIGSTAT=-Dm4METHODI=SIG -Dm4METHODR=STAT
SIGSTAT=edhoc_SIG_STAT.spthy
TSIGSTAT=TMP_${SIGSTAT}
MSTATSIG=-Dm4METHODI=STAT -Dm4METHODR=SIG
STATSIG=edhoc_STAT_SIG.spthy
TSTATSIG=TMP_${STATSIG}
MSTATSTAT=-Dm4METHODI=STAT -Dm4METHODR=STAT
STATSTAT=edhoc_STAT_STAT.spthy
TSTATSTAT=TMP_${STATSTAT}
MPSKPSK=-Dm4METHODI=PSK -Dm4METHODR=PSK
PSKPSK=edhoc_PSK_PSK.spthy
TPSKPSK=TMP_${PSKPSK}
XORMODEL=FULL
MXOR=-Dm4XOR=${XORMODEL}

SPTHYS=${PSKPSK} ${SIGSIG} ${STATSIG} ${SIGSTAT} ${STATSTAT}

# Using GNU time we can get more useful information about memory and time
# consumption.
# We log in this format: "[hours:]:minutes:seconds MB-of-memory"
# Time is measured in real time, becasue we care about how long we actually
# have to wait for verification runs
TIMEFMT=%E
TIME=/usr/bin/time -f ${TIMEFMT}


# Don't change the METH string or the LEMMAPREFIX strings. They are used
# as variables in substitutions below
TIME_PROVE_AND_LOG=(time ${TAMARIN} --prove=LEMMAPREFIX TMP_METH) 2>&1 | gzip > ${PROOFS}/LEMMAPREFIX-METH.gz ;

# Use this to discard all proofs and only see the results
#TIME_PROVE_AND_LOG=(time ${TAMARIN} --prove=LEMMAPREFIX TMP_METH) 2>/dev/null | gzip > ${PROOFS}/LEMMAPREFIX-METH.gz ;

check:
	zgrep --color=auto -E "verified|falsified|Killed|(user.*m.*s)|(real.*m.*s)" ${PROOFS}/*

proofdir:
	mkdir -p ${PROOFS}

genModels: proofdir
	m4 ${MFLAGS} ${MSIGSTAT} ${MXOR} ${SRC} > ${TSIGSTAT}
	m4 ${MFLAGS} ${MSTATSIG} ${MXOR} ${SRC} > ${TSTATSIG}
	m4 ${MFLAGS} ${MSTATSTAT} ${MXOR} ${SRC} > ${TSTATSTAT}
	m4 ${MFLAGS} ${MSIGSIG} ${MXOR} ${SRC} > ${TSIGSIG}
	m4 ${MFLAGS} ${MPSKPSK} ${MXOR} ${SRC} > ${TPSKPSK}

# This target is useful for viewing the GUI
interactive: genModels
	${TAMARIN_CLEAN} interactive ./ -b=5 --quit-on-warning --heuristic=O --oraclename=oracle.py

# This target checks that all models parses correctly
sense: genModels
	$(foreach meth,${SPTHYS},\
		${TAMARIN_CLEAN} --parse-only TMP_$(meth) 2>&1\
			| grep --color=auto -E "analyzed|error|tamarin-prover:.*";\
	 )

# This target verifies all lemmas beginning with "sanity" for all models
alotofsense: genModels
	$(foreach meth,${SPTHYS},\
		$(subst METH,$(meth),\
			$(subst LEMMAPREFIX,sanity*,${TIME_PROVE_AND_LOG})\
		 )\
	 )

# Extra validation lemmas
VALID_LEMMAS= validAuthDifferentKeysPosssible \
		      validAuthDifferentKeysPosssible2 \
			  validAuthDifferentPartiesSameKey \
			  validAuthDifferentPartiesSameKey2

valid: genModels
	$(foreach lemma, ${VALID_LEMMAS}, $(subst LEMMA,$(lemma),\
		$(foreach meth,${SPTHYS}, $(subst METH,$(meth),\
			$(subst LEMMAPREFIX,LEMMA,${TIME_PROVE_AND_LOG})\
		))\
	))

# Injective agreement on session key except when G_IY is included for I.
# Inj-agreement for full session key for R.
authInjAgree: genModels
	$(foreach meth,${SPTHYS},\
		$(subst METH,$(meth),\
			$(subst LEMMAPREFIX,authInj*,${TIME_PROVE_AND_LOG})\
		 )\
	 )

# Implicit agreement. Covers all keying material
authImplicit: genModels
	$(foreach meth,${SPTHYS},\
		$(subst METH,$(meth),\
			$(subst LEMMAPREFIX,authImplicit*,${TIME_PROVE_AND_LOG})\
		 )\
	 )

auth: authInjAgree authImplicit

pfs: genModels
	$(foreach meth,${SPTHYS},\
		$(subst METH,$(meth),\
			$(subst LEMMAPREFIX,secrecyPFS*,${TIME_PROVE_AND_LOG})\
		 )\
	 )

ad3: genModels
	$(foreach meth,${SPTHYS},\
		$(subst METH,$(meth),\
			$(subst LEMMAPREFIX,securityAD_*,${TIME_PROVE_AND_LOG})\
		 )\
	 )

all: proofdir sense alotofsense auth pfs ad3

clean:
	rm ./TMP_*.spthy

cleanproofs:
	rm ./${PROOFS}/*.spthy

proverifAll:
	proverif ${LOADLIB} ${MODEL}

proverifRes:
	proverif ${LOADLIB} ${MODEL} | grep RESULT

proverifTst:
	proverif ${LOADLIB} ${TEST}

