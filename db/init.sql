-- ==========================================================
-- init.sql
-- Project 4: Bioinformatics Algorithm Database
-- ==========================================================

-- 1. Initialize Database and Schema
-- ----------------------------------------------------------
CREATE DATABASE IF NOT EXISTS bioalgodb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bioalgodb;

-- Disable foreign key checks for bulk insertion
SET FOREIGN_KEY_CHECKS = 0;

-- Table: problem
CREATE TABLE IF NOT EXISTS problem (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  CONSTRAINT uq_problem_name UNIQUE (name),
  INDEX idx_problem_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: algorithm
CREATE TABLE IF NOT EXISTS algorithm (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  problem_id BIGINT NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  year INT,
  CONSTRAINT fk_algorithm_problem FOREIGN KEY (problem_id) REFERENCES problem(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT uq_algorithm_name UNIQUE (name),
  INDEX idx_algorithm_name (name),
  INDEX idx_algorithm_description (description(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: lab
CREATE TABLE IF NOT EXISTS lab (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  institution VARCHAR(255),
  country VARCHAR(100),
  website VARCHAR(255),
  description TEXT,
  CONSTRAINT uq_lab_name UNIQUE (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: tool
CREATE TABLE IF NOT EXISTS tool (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  algorithm_id BIGINT NOT NULL,
  lab_id BIGINT,
  name VARCHAR(255) NOT NULL,
  version VARCHAR(50),
  description TEXT,
  website VARCHAR(255),
  license VARCHAR(100),
  CONSTRAINT fk_tool_algorithm FOREIGN KEY (algorithm_id) REFERENCES algorithm(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_tool_lab FOREIGN KEY (lab_id) REFERENCES lab(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT uq_tool_name UNIQUE (name),
  INDEX idx_tool_algorithm (algorithm_id),
  INDEX idx_tool_lab (lab_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: paper
CREATE TABLE IF NOT EXISTS paper (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  year INT,
  doi VARCHAR(128),
  journal VARCHAR(255),
  authors TEXT,
  CONSTRAINT uq_paper_doi UNIQUE (doi)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: algorithm_paper
CREATE TABLE IF NOT EXISTS algorithm_paper (
  algorithm_id BIGINT NOT NULL,
  paper_id BIGINT NOT NULL,
  PRIMARY KEY (algorithm_id, paper_id),
  CONSTRAINT fk_algpaper_algorithm FOREIGN KEY (algorithm_id) REFERENCES algorithm(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_algpaper_paper FOREIGN KEY (paper_id) REFERENCES paper(id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: tool_paper
CREATE TABLE IF NOT EXISTS tool_paper (
  tool_id BIGINT NOT NULL,
  paper_id BIGINT NOT NULL,
  PRIMARY KEY (tool_id, paper_id),
  CONSTRAINT fk_toolpaper_tool FOREIGN KEY (tool_id) REFERENCES tool(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_toolpaper_paper FOREIGN KEY (paper_id) REFERENCES paper(id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: user
CREATE TABLE IF NOT EXISTS user (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(150) NOT NULL,
  email VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('admin','user') NOT NULL DEFAULT 'user',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_user_username UNIQUE (username),
  CONSTRAINT uq_user_email UNIQUE (email),
  INDEX idx_user_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Clear existing data to ensure clean slate for the 9 specific problems
TRUNCATE TABLE tool_paper;
TRUNCATE TABLE algorithm_paper;
TRUNCATE TABLE paper;
TRUNCATE TABLE tool;
TRUNCATE TABLE algorithm;
TRUNCATE TABLE problem;
TRUNCATE TABLE lab;
TRUNCATE TABLE user;

-- 2. Insert Data: Problems (9 Categories)
-- ----------------------------------------------------------
INSERT INTO problem (id, name, description) VALUES
 (1, 'Sequence Alignment', 'Arranging sequences of DNA, RNA, or protein to identify regions of similarity.'),
 (2, 'Short Read Mapping', 'Aligning short DNA sequences (reads) from NGS to a large reference genome.'),
 (3, 'Genome Assembly', 'Reconstructing chromosomes or genomes from sequenced reads (De novo).'),
 (4, 'Gene Discovery', 'Identifying coding regions (genes) within genomic DNA (Gene Prediction).'),
 (5, 'Motif Discovery', 'Finding recurring patterns (motifs) in sequences, often binding sites.'),
 (6, 'Phylogenetic Reconstruction', 'Inferring evolutionary relationships and building trees among biological entities.'),
 (7, 'Functional Annotation', 'Attaching biological information (GO terms, pathways) to sequences.'),
 (8, 'Secondary Structure Prediction', 'Predicting alpha-helices/beta-sheets (Protein) or stem-loops (RNA).'),
 (9, 'Tertiary Structure Prediction', 'Predicting the 3D coordinates of protein atoms from amino acid sequences.');

-- 3. Insert Data: Algorithms (3 per Problem = 27 Total)
-- ----------------------------------------------------------
INSERT INTO algorithm (id, problem_id, name, description, year) VALUES
 -- 1. Sequence Alignment
 (1, 1, 'BLAST', 'Heuristic local alignment search tool using seed-and-extend.', 1990),
 (2, 1, 'Smith-Waterman', 'Dynamic programming algorithm for guaranteed optimal local alignment.', 1981),
 (3, 1, 'Clustal Omega', 'Scalable multiple sequence alignment using seeded guide trees and HMM profiles.', 2011),

 -- 2. Short Read Mapping
 (4, 2, 'BWA', 'Burrows-Wheeler Aligner for aligning low-divergent sequences against a large reference.', 2009),
 (5, 2, 'Bowtie2', 'Ultrafast and memory-efficient tool for aligning sequencing reads using FM-index.', 2012),
 (6, 2, 'STAR', 'Spliced Transcripts Alignment to a Reference; ultrafast RNA-seq aligner.', 2013),

 -- 3. Genome Assembly
 (7, 3, 'SPAdes', 'Versatile toolkit for single-cell and small genome assembly using de Bruijn graphs.', 2012),
 (8, 3, 'Canu', 'Specialized assembler for high-noise long-read sequencing (PacBio/Nanopore).', 2017),
 (9, 3, 'MEGAHIT', 'Ultra-fast single-node solution for large complex metagenomics assembly.', 2015),

 -- 4. Gene Discovery
 (10, 4, 'Augustus', 'HMM-based gene prediction for eukaryotic genomes.', 2003),
 (11, 4, 'Prodigal', 'Fast, reliable protein-coding gene prediction for prokaryotic genomes.', 2010),
 (12, 4, 'Glimmer', 'Gene detection in microbial DNA using interpolated Markov models.', 1998),

 -- 5. Motif Discovery
 (13, 5, 'MEME Suite', 'Toolkit for motif discovery (EM algorithm) and enrichment analysis.', 1994),
 (14, 5, 'HOMER', 'Hypergeometric Optimization of Motif EnRichment for NGS analysis.', 2010),
 (15, 5, 'Weeder', 'Suffix tree based motif discovery algorithm.', 2001),

 -- 6. Phylogenetic Reconstruction
 (16, 6, 'RAxML', 'Randomized Axelerated Maximum Likelihood for phylogenetic tree inference.', 2006),
 (17, 6, 'IQ-TREE', 'Efficient phylogenomic software with automatic model selection.', 2015),
 (18, 6, 'MrBayes', 'Bayesian inference of phylogeny using Markov chain Monte Carlo (MCMC).', 2001),

 -- 7. Functional Annotation
 (19, 7, 'Blast2GO', 'All-in-one functional annotation with Gene Ontology vocabulary.', 2005),
 (20, 7, 'InterProScan', 'Scans sequences against InterPro protein signature databases.', 2005),
 (21, 7, 'KAAS', 'KEGG Automatic Annotation Server for pathway mapping.', 2007),

 -- 8. Secondary Structure Prediction
 (22, 8, 'PSIPRED', 'Protein secondary structure prediction based on PSI-BLAST profiles.', 1999),
 (23, 8, 'RNAfold', 'Prediction of RNA secondary structures using minimum free energy (ViennaRNA).', 2003),
 (24, 8, 'JPred', 'A neural network-based secondary structure prediction server.', 1998),

 -- 9. Tertiary Structure Prediction
 (25, 9, 'AlphaFold2', 'AI system by DeepMind predicting 3D structure with experimental accuracy.', 2021),
 (26, 9, 'Rosetta', 'Software suite for macromolecular modeling and ab initio design.', 2004),
 (27, 9, 'I-TASSER', 'Iterative Threading ASSEmbly Refinement for protein structure prediction.', 2008);

-- 4. Insert Data: Papers 
-- ----------------------------------------------------------
INSERT INTO paper (id, title, year, doi, journal, authors) VALUES
 -- Algo 1: BLAST
 (1, 'Basic local alignment search tool', 1990, '10.1016/S0022-2836(05)80360-2', 'Journal of Molecular Biology', 'Altschul SF; Gish W; Miller W; et al.'),
 (2, 'Gapped BLAST and PSI-BLAST: a new generation of protein database search programs', 1997, '10.1093/nar/25.17.3389', 'Nucleic Acids Research', 'Altschul SF; Madden TL; Schaffer AA; et al.'),
 (3, 'BLAST+: architecture and applications', 2009, '10.1186/1471-2105-10-421', 'BMC Bioinformatics', 'Camacho C; Coulouris G; Avagyan V; et al.'),

 -- Algo 2: Smith-Waterman
 (4, 'Identification of common molecular subsequences', 1981, '10.1016/0022-2836(81)90087-5', 'Journal of Molecular Biology', 'Smith TF; Waterman MS'),
 (5, 'An improved algorithm for matching biological sequences', 1982, '10.1016/0022-2836(82)90398-9', 'Journal of Molecular Biology', 'Gotoh O'),
 (6, 'Striped Smith-Waterman speeds database searches six times over other SIMD implementations', 2007, '10.1093/bioinformatics/btl582', 'Bioinformatics', 'Farrar M'),

 -- Algo 3: Clustal Omega
 (7, 'Fast, scalable generation of high-quality protein multiple sequence alignments using Clustal Omega', 2011, '10.1038/msb.2011.75', 'Molecular Systems Biology', 'Sievers F; Wilm A; Dineen D; et al.'),
 (8, 'Clustal Omega for making accurate alignments of many protein sequences', 2018, '10.1002/pro.3290', 'Protein Science', 'Sievers F; Higgins DG'),
 (9, 'Benchmarking multiple sequence alignment methods for large datasets', 2010, '10.1093/nar/gkq443', 'Nucleic Acids Research', 'Blackshields G; Sievers F; Shi W; et al.'),

 -- Algo 4: BWA
 (10, 'Fast and accurate short read alignment with Burrows-Wheeler transform', 2009, '10.1093/bioinformatics/btp324', 'Bioinformatics', 'Li H; Durbin R'),
 (11, 'Fast and accurate long-read alignment with Burrows-Wheeler transform', 2010, '10.1093/bioinformatics/btp698', 'Bioinformatics', 'Li H; Durbin R'),
 (12, 'Aligning sequence reads, clone sequences and assembly contigs with BWA-MEM', 2013, 'arXiv:1303.3997', 'arXiv preprint', 'Li H'),

 -- Algo 5: Bowtie2
 (13, 'Fast gapped-read alignment with Bowtie 2', 2012, '10.1038/nmeth.1923', 'Nature Methods', 'Langmead B; Salzberg SL'),
 (14, 'Ultrafast and memory-efficient alignment of short DNA sequences to the human genome', 2009, '10.1186/gb-2009-10-3-r25', 'Genome Biology', 'Langmead B; Trapnell C; Pop M; Salzberg SL'),
 (15, 'Cloud-scale Bowtie: alignment of reads in the cloud', 2010, '10.1093/bioinformatics/btq531', 'Bioinformatics', 'Langmead B; Schatz MC; Lin J; et al.'),

 -- Algo 6: STAR
 (16, 'STAR: ultrafast universal RNA-seq aligner', 2013, '10.1093/bioinformatics/bts635', 'Bioinformatics', 'Dobin A; Davis CA; Schlesinger F; et al.'),
 (17, 'Mapping RNA-seq Reads with STAR', 2015, '10.1002/0471250953.bi1114s51', 'Current Protocols in Bioinformatics', 'Dobin A; Gingeras TR'),
 (18, 'STAR-Fusion: Fast and Accurate Fusion Transcript Detection from RNA-Seq', 2017, '10.1101/120295', 'bioRxiv', 'Haas BJ; Dobin A; Li B; et al.'),

 -- Algo 7: SPAdes
 (19, 'SPAdes: a new genome assembly algorithm and its applications to single-cell sequencing', 2012, '10.1089/cmb.2012.0021', 'Journal of Computational Biology', 'Bankevich A; Nurk S; Antipov D; et al.'),
 (20, 'Using SPAdes De Novo Assembler', 2020, '10.1002/cpbi.102', 'Current Protocols in Bioinformatics', 'Prjibelski A; Antipov D; Meleshko D; et al.'),
 (21, 'plasmidSPAdes: assembling plasmids from whole genome sequencing data', 2016, '10.1093/bioinformatics/btw493', 'Bioinformatics', 'Antipov D; Hartwick N; Shen M; et al.'),

 -- Algo 8: Canu
 (22, 'Canu: scalable and accurate long-read assembly via adaptive k-mer weighting and repeat separation', 2017, '10.1101/gr.215087.116', 'Genome Research', 'Koren S; Walenz BP; Berlin K; et al.'),
 (23, 'HiCanu: accurate assembly of segmental duplications, satellites, and allelic variants from high-fidelity long reads', 2020, '10.1101/gr.263566.120', 'Genome Research', 'Nurk S; Walenz BP; Rhie A; et al.'),
 (24, 'Assembly of long, error-prone reads using repeat graphs', 2017, '10.1093/bioinformatics/btx233', 'Bioinformatics', 'Kamath GM; Shomorony I; Xia F; et al.'),

 -- Algo 9: MEGAHIT
 (25, 'MEGAHIT: an ultra-fast single-node solution for large and complex metagenomics assembly via succinct de Bruijn graph', 2015, '10.1093/bioinformatics/btv033', 'Bioinformatics', 'Li D; Liu CM; Luo R; et al.'),
 (26, 'MEGAHIT v1.0: A fast and scalable metagenome assembler driven by advanced topologies', 2016, '10.1016/j.ymeth.2016.02.020', 'Methods', 'Li D; Luo R; Liu CM; et al.'),
 (27, 'Comparison of the performance of metagenomic assemblers on simulated data', 2017, '10.1371/journal.pone.0169662', 'PLoS One', 'Vollmers J; Wiegand S; Kaster AK'),

 -- Algo 10: Augustus
 (28, 'Gene prediction with a hidden Markov model and a new intron submodel', 2003, '10.1093/bioinformatics/btg1080', 'Bioinformatics', 'Stanke M; Waack S'),
 (29, 'Gene prediction in eukaryotes with a generalized hidden Markov model that uses hints from external sources', 2006, '10.1186/1471-2105-7-62', 'BMC Bioinformatics', 'Stanke M; Schoffmann O; Morgenstern B; et al.'),
 (30, 'Web server for automated eukaryotic genome annotation', 2013, '10.1093/nar/gkt418', 'Nucleic Acids Research', 'Hoff KJ; Stanke M'),

 -- Algo 11: Prodigal
 (31, 'Prodigal: prokaryotic gene recognition and translation initiation site identification', 2010, '10.1186/1471-2105-11-119', 'BMC Bioinformatics', 'Hyatt D; Chen GL; LoCascio PF; et al.'),
 (32, 'Metagenomic Data Analysis Methods', 2012, '10.1007/978-1-4614-1661-4', 'Springer', 'Kelley D; Liu B; Delcher A; et al.'),
 (33, 'Gene Prediction in Metagenomic Sequences', 2012, '10.1007/978-1-61779-585-5_13', 'Metagenomics', 'Hyatt D; LoCascio PF; Hauser LJ; et al.'),

 -- Algo 12: Glimmer
 (34, 'Microbial gene identification using interpolated Markov models', 1998, '10.1093/nar/26.2.544', 'Nucleic Acids Research', 'Salzberg SL; Delcher AL; Kasif S; et al.'),
 (35, 'Improved microbial gene identification with GLIMMER', 1999, '10.1093/nar/27.23.4636', 'Nucleic Acids Research', 'Delcher AL; Harmon D; Kasif S; et al.'),
 (36, 'Identifying bacterial genes and endosymbiont DNA with Glimmer', 2007, '10.1093/bioinformatics/btm009', 'Bioinformatics', 'Delcher AL; Bratke KA; Powers EC; et al.'),

 -- Algo 13: MEME Suite
 (37, 'Fitting a mixture model by expectation maximization to discover motifs in biopolymers', 1994, 'AAI9502099', 'ISMB', 'Bailey TL; Elkan C'),
 (38, 'MEME SUITE: tools for motif discovery and searching', 2009, '10.1093/nar/gkp335', 'Nucleic Acids Research', 'Bailey TL; Boden M; Buske FA; et al.'),
 (39, 'MEME-ChIP: motif analysis of large DNA datasets', 2011, '10.1093/bioinformatics/btr189', 'Bioinformatics', 'Machanick P; Bailey TL'),

 -- Algo 14: HOMER
 (40, 'Simple combinations of lineage-determining transcription factors prime cis-regulatory elements', 2010, '10.1016/j.molcel.2010.05.004', 'Molecular Cell', 'Heinz S; Benner C; Spann N; et al.'),
 (41, 'HOMER: A Software for Motif Discovery and Next-Generation Sequencing Analysis', 2010, 'Software-URL-1', 'UCSD', 'Heinz S; et al.'),
 (42, 'Cross-species identification of genomic regulatory elements and their features', 2019, '10.1101/gr.254821.119', 'Genome Research', 'Duttke SH; Chang MW; Heinz S; et al.'),

 -- Algo 15: Weeder
 (43, 'On the identification of overlapping motifs in biological sequences', 2001, '10.1089/106652701300099074', 'Journal of Computational Biology', 'Pavesi G; Mauri G; Pesole G'),
 (44, 'Weeder Web: discovery of transcription factor binding sites in a set of sequences from co-regulated genes', 2004, '10.1093/nar/gkh465', 'Nucleic Acids Research', 'Pavesi G; Mereghetti P; Mauri G; et al.'),
 (45, 'Weeder 2.0: transcription factor binding site discovery in large datasets', 2014, '10.1093/nar/gku1020', 'Nucleic Acids Research', 'Zambelli F; Pesole G; Pavesi G'),

 -- Algo 16: RAxML
 (46, 'RAxML version 8: a tool for phylogenetic analysis and post-analysis of large phylogenies', 2014, '10.1093/bioinformatics/btu033', 'Bioinformatics', 'Stamatakis A'),
 (47, 'RAxML-VI-HPC: maximum likelihood-based phylogenetic analyses with thousands of taxa and mixed models', 2006, '10.1093/bioinformatics/btl446', 'Bioinformatics', 'Stamatakis A'),
 (48, 'RAxML-NG: a fast, scalable and user-friendly tool for maximum likelihood phylogenetic inference', 2019, '10.1093/bioinformatics/btz305', 'Bioinformatics', 'Kozlov AM; Darriba D; Flouri T; et al.'),

 -- Algo 17: IQ-TREE
 (49, 'IQ-TREE: a fast and effective stochastic algorithm for estimating maximum-likelihood phylogenies', 2015, '10.1093/molbev/msu300', 'Molecular Biology and Evolution', 'Nguyen LT; Schmidt HA; von Haeseler A; et al.'),
 (50, 'ModelFinder: fast model selection for accurate phylogenetic estimates', 2017, '10.1038/nmeth.4285', 'Nature Methods', 'Kalyaanamoorthy S; Minh BQ; Wong TKF; et al.'),
 (51, 'UFBoot2: Improving the Ultrafast Bootstrap Approximation', 2018, '10.1093/molbev/msx281', 'Molecular Biology and Evolution', 'Hoang DT; Chernomor O; von Haeseler A; et al.'),

 -- Algo 18: MrBayes
 (52, 'MRBAYES: Bayesian inference of phylogenetic trees', 2001, '10.1093/bioinformatics/17.8.754', 'Bioinformatics', 'Huelsenbeck JP; Ronquist F'),
 (53, 'MrBayes 3.2: efficient Bayesian phylogenetic inference and model choice across a large model space', 2012, '10.1093/sysbio/sys029', 'Systematic Biology', 'Ronquist F; Teslenko M; van der Mark P; et al.'),
 (54, 'MrBayes 3: Bayesian phylogenetic inference under mixed models', 2003, '10.1093/bioinformatics/btg180', 'Bioinformatics', 'Ronquist F; Huelsenbeck JP'),

 -- Algo 19: Blast2GO
 (55, 'Blast2GO: a universal tool for annotation, visualization and analysis in functional genomics research', 2005, '10.1093/bioinformatics/bti610', 'Bioinformatics', 'Conesa A; Gotz S; Garcia-Gomez JM; et al.'),
 (56, 'High-throughput functional annotation and data mining with the Blast2GO suite', 2008, '10.1093/nar/gkn176', 'Nucleic Acids Research', 'Gotz S; Garcia-Gomez JM; Terol J; et al.'),
 (57, 'Blast2GO: A Comprehensive Suite for Functional Analysis in Plant Genomics', 2008, '10.1155/2008/619832', 'International Journal of Plant Genomics', 'Conesa A; Gotz S'),

 -- Algo 20: InterProScan
 (58, 'InterProScan: protein domains identifier', 2005, '10.1093/nar/gki442', 'Nucleic Acids Research', 'Quevillon E; Silventoinen V; Pillai S; et al.'),
 (59, 'InterProScan 5: genome-scale protein function classification', 2014, '10.1093/bioinformatics/btu031', 'Bioinformatics', 'Jones P; Binns D; Chang HY; et al.'),
 (60, 'The InterPro protein families and domains database: 20 years on', 2021, '10.1093/nar/gkaa977', 'Nucleic Acids Research', 'Blum M; Chang HY; Chuguransky S; et al.'),

 -- Algo 21: KAAS (KEGG)
 (61, 'KAAS: an automatic genome annotation and pathway reconstruction server', 2007, '10.1093/nar/gkm321', 'Nucleic Acids Research', 'Moriya Y; Itoh M; Okuda S; et al.'),
 (62, 'KEGG: Kyoto Encyclopedia of Genes and Genomes', 2000, '10.1093/nar/28.1.27', 'Nucleic Acids Research', 'Kanehisa M; Goto S'),
 (63, 'KofamKOALA: KEGG Ortholog assignment based on HMM profile search', 2020, '10.1093/bioinformatics/btz859', 'Bioinformatics', 'Aramaki T; Blanc-Mathieu R; Endo H; et al.'),

 -- Algo 22: PSIPRED
 (64, 'Protein secondary structure prediction based on position-specific scoring matrices', 1999, '10.1006/jmbi.1999.3091', 'Journal of Molecular Biology', 'Jones DT'),
 (65, 'The PSIPRED Protein Analysis Workbench: 20 years on', 2019, '10.1093/nar/gkz297', 'Nucleic Acids Research', 'Buchan DWA; Jones DT'),
 (66, 'The PSIPRED protein structure prediction server', 2000, '10.1093/bioinformatics/16.4.404', 'Bioinformatics', 'McGuffin LJ; Bryson K; Jones DT'),

 -- Algo 23: RNAfold
 (67, 'ViennaRNA Package 2.0', 2011, '10.1186/1748-7188-6-26', 'Algorithms for Molecular Biology', 'Lorenz R; Bernhart SH; Honer Zu Siederdissen C; et al.'),
 (68, 'Vienna RNA secondary structure server', 2003, '10.1093/nar/gkg599', 'Nucleic Acids Research', 'Hofacker IL'),
 (69, 'The equilibrium partition function and base pair binding probabilities for RNA secondary structure', 1990, '10.1002/bip.360290621', 'Biopolymers', 'McCaskill JS'),

 -- Algo 24: JPred
 (70, 'JPred: a consensus secondary structure prediction server', 1998, '10.1093/bioinformatics/14.10.892', 'Bioinformatics', 'Cuff JA; Clamp M; Siddiqui AS; et al.'),
 (71, 'The Jpred 3 secondary structure prediction server', 2008, '10.1093/nar/gkn238', 'Nucleic Acids Research', 'Cole C; Barber JD; Barton GJ'),
 (72, 'JPred4: a protein secondary structure prediction server', 2015, '10.1093/nar/gkv332', 'Nucleic Acids Research', 'Drozdetskiy A; Cole C; Barber JD; et al.'),

 -- Algo 25: AlphaFold2
 (73, 'Highly accurate protein structure prediction with AlphaFold', 2021, '10.1038/s41586-021-03819-2', 'Nature', 'Jumper J; Evans R; Pritzel A; et al.'),
 (74, 'AlphaFold Protein Structure Database: massively expanding the structural coverage of protein-sequence space', 2022, '10.1093/nar/gkab1061', 'Nucleic Acids Research', 'Varadi M; Anyango S; Deshpande M; et al.'),
 (75, 'Protein complex prediction with AlphaFold-Multimer', 2021, '10.1101/2021.10.04.463034', 'bioRxiv', 'Evans R; ONeill M; Pritzel A; et al.'),

 -- Algo 26: Rosetta
 (76, 'Protein structure prediction using Rosetta', 2004, '10.1016/S0076-6879(04)83002-6', 'Methods in Enzymology', 'Rohl CA; Strauss CE; Misura KM; et al.'),
 (77, 'ROSETTA3: an object-oriented software suite for the simulation and design of macromolecules', 2011, '10.1016/B978-0-12-381270-4.00019-6', 'Methods in Enzymology', 'Leaver-Fay A; Tyka M; Lewis SM; et al.'),
 (78, 'The Rosetta All-Atom Energy Function for Macromolecular Modeling and Design', 2017, '10.1021/acs.jctc.7b00125', 'Journal of Chemical Theory and Computation', 'Alford RF; Leaver-Fay A; Jeliazkov JR; et al.'),

 -- Algo 27: I-TASSER
 (79, 'I-TASSER server for protein 3D structure prediction', 2008, '10.1186/1471-2105-9-40', 'BMC Bioinformatics', 'Zhang Y'),
 (80, 'I-TASSER: a unified platform for automated protein structure and function prediction', 2010, '10.1038/nprot.2010.5', 'Nature Protocols', 'Roy A; Kucukural A; Zhang Y'),
 (81, 'The I-TASSER Suite: protein structure and function prediction', 2015, '10.1038/nmeth.3213', 'Nature Methods', 'Yang J; Yan R; Roy A; et al.');

-- 5. Link Algorithms to Papers
-- ----------------------------------------------------------
INSERT INTO algorithm_paper (algorithm_id, paper_id) VALUES
 (1,1), (1,2), (1,3),     -- BLAST
 (2,4), (2,5), (2,6),     -- Smith-Waterman
 (3,7), (3,8), (3,9),     -- Clustal Omega
 (4,10), (4,11), (4,12),  -- BWA
 (5,13), (5,14), (5,15),  -- Bowtie2
 (6,16), (6,17), (6,18),  -- STAR
 (7,19), (7,20), (7,21),  -- SPAdes
 (8,22), (8,23), (8,24),  -- Canu
 (9,25), (9,26), (9,27),  -- MEGAHIT
 (10,28), (10,29), (10,30), -- Augustus
 (11,31), (11,32), (11,33), -- Prodigal
 (12,34), (12,35), (12,36), -- Glimmer
 (13,37), (13,38), (13,39), -- MEME
 (14,40), (14,41), (14,42), -- HOMER
 (15,43), (15,44), (15,45), -- Weeder
 (16,46), (16,47), (16,48), -- RAxML
 (17,49), (17,50), (17,51), -- IQ-TREE
 (18,52), (18,53), (18,54), -- MrBayes
 (19,55), (19,56), (19,57), -- Blast2GO
 (20,58), (20,59), (20,60), -- InterProScan
 (21,61), (21,62), (21,63), -- KAAS
 (22,64), (22,65), (22,66), -- PSIPRED
 (23,67), (23,68), (23,69), -- RNAfold
 (24,70), (24,71), (24,72), -- JPred
 (25,73), (25,74), (25,75), -- AlphaFold2
 (26,76), (26,77), (26,78), -- Rosetta
 (27,79), (27,80), (27,81); -- I-TASSER

-- 6. Insert Users (Default)
-- ----------------------------------------------------------
INSERT IGNORE INTO user (id, username, email, password_hash, role) VALUES
  (1,'admin','admin@example.com','scrypt:32768:8:1$jUIUoFgfP6eoAcT6$ca95d6211eb0ab5aaaaa9028fdcdbbeec6672e738ac3adcd536510433eac8a4ed4bc2b8eeed05ed9225fded8e1cff5b9abe3ad32b0eff0a93e1ec95115f05595','admin'),
  (2,'alice','alice@example.com','$2b$12$P7lvtTDHkJ/xZBwbNG0OUeZ7Z2qxdjQbaO5jM90oCbGyF/F7kh/3G','user'),
  (3,'bob','bob@example.com','$2b$12$z71oJKVQ1BM8DT6vKrrO5evYv7FpC18JNpDutLCRa14Q6gttxyP1q','user');

-- 7. Insert Labs (Expanded List)
-- 包含主要算法背后的著名实验室和研究机构
-- ----------------------------------------------------------
INSERT IGNORE INTO lab (id, name, institution, country, website, description) VALUES
 (1, 'NCBI', 'National Center for Biotechnology Information', 'USA', 'https://www.ncbi.nlm.nih.gov', 'Resource for molecular biology information, home of BLAST.'),
 (2, 'DeepMind', 'Google DeepMind', 'UK', 'https://www.deepmind.com', 'AI research lab, creator of AlphaFold.'),
 (3, 'EBI', 'European Bioinformatics Institute', 'UK', 'https://www.ebi.ac.uk', 'Bioinformatics services and research, host of InterPro, Clustal, etc.'),
 (4, 'Baker Lab', 'University of Washington', 'USA', 'https://www.bakerlab.org', 'Lab specialized in protein design (Rosetta).'),
 (5, 'JHU CCB', 'Johns Hopkins University', 'USA', 'https://ccb.jhu.edu', 'Center for Computational Biology (Salzberg Lab - Bowtie, Glimmer, HISAT).'),
 (6, 'HITS', 'Heidelberg Institute for Theoretical Studies', 'Germany', 'https://www.h-its.org', 'Home of the Exelixis Lab (Alexandros Stamatakis - RAxML).'),
 (7, 'CAB SPbU', 'Saint Petersburg State University', 'Russia', 'http://cab.spbu.ru', 'Center for Algorithmic Biotechnology (SPAdes).'),
 (8, 'Dobin Lab', 'Cold Spring Harbor Laboratory', 'USA', 'http://www.cshl.edu', 'Creators of STAR aligner.'),
 (9, 'TBI Vienna', 'University of Vienna', 'Austria', 'https://www.tbi.univie.ac.at', 'Institute for Theoretical Chemistry (ViennaRNA Package).'),
 (10, 'Zhang Lab', 'University of Michigan', 'USA', 'https://zhanggroup.org', 'Lab focusing on protein structure prediction (I-TASSER).'),
 (11, 'Bailey Lab', 'University of Nevada, Reno', 'USA', 'https://www.meme-suite.org', 'Maintainers of the MEME Suite.'),
 (12, 'Benner Lab', 'University of California, San Diego', 'USA', 'http://homer.ucsd.edu', 'Developers of HOMER.'),
 (13, 'Barton Group', 'University of Dundee', 'UK', 'http://www.compbio.dundee.ac.uk', 'Computational Biology group (JPred).'),
 (14, 'UCL Bioinf', 'University College London', 'UK', 'http://bioinf.cs.ucl.ac.uk', 'Bioinformatics Group (PSIPRED).'),
 (15, 'NHGRI', 'National Institutes of Health', 'USA', 'https://www.genome.gov', 'Genome Informatics Section (Canu, Adam Phillippy).'),
 (16, 'HKU-L3', 'University of Hong Kong', 'China', 'https://github.com/voutcn/megahit', 'L3 Bioinformatics Limited (MEGAHIT).'),
 (17, 'Greifswald Bioinf', 'University of Greifswald', 'Germany', 'http://augustus.gobics.de', 'Department of Bioinformatics (Augustus).');

-- 8. Insert Tools (Expanded List - Linked to Algorithms and Labs)
-- ----------------------------------------------------------
INSERT IGNORE INTO tool (id, algorithm_id, lab_id, name, version, description, website, license) VALUES
 -- Sequence Alignment
 (1, 1, 1, 'BLAST+', '2.15.0', 'Command line BLAST tools for local search.', 'https://blast.ncbi.nlm.nih.gov', 'Public Domain'),
 (2, 2, 3, 'EMBOSS Water', '6.6.0', 'Smith-Waterman local alignment tool via EMBOSS.', 'https://www.ebi.ac.uk/Tools/psa/emboss_water/', 'GPL'),
 (3, 3, 3, 'Clustal Omega', '1.2.4', 'Scalable multiple sequence alignment tool.', 'http://www.clustal.org/omega/', 'GPL'),

 -- Short Read Mapping
 (4, 4, 3, 'BWA', '0.7.17', 'Burrows-Wheeler Aligner (BWA-MEM recommended).', 'http://bio-bwa.sourceforge.net', 'GPLv3'),
 (5, 5, 5, 'Bowtie2', '2.5.3', 'Fast and sensitive read alignment.', 'http://bowtie-bio.sourceforge.net/bowtie2', 'GPLv3'),
 (6, 6, 8, 'STAR', '2.7.11a', 'Ultrafast universal RNA-seq aligner.', 'https://github.com/alexdobin/STAR', 'GPLv3'),

 -- Genome Assembly
 (7, 7, 7, 'SPAdes', '3.15.5', 'Genome assembler for single-cell and isolates.', 'http://cab.spbu.ru/software/spades/', 'GPLv2'),
 (8, 8, 15, 'Canu', '2.2', 'High-noise long-read assembler (PacBio/Nanopore).', 'https://github.com/marbl/canu', 'GPLv2'),
 (9, 9, 16, 'MEGAHIT', '1.2.9', 'Ultra-fast metagenomics assembler.', 'https://github.com/voutcn/megahit', 'GPLv3'),

 -- Gene Discovery
 (10, 10, 17, 'Augustus', '3.5.0', 'Eukaryotic gene predictor.', 'http://augustus.gobics.de/', 'Artistic License'),
 (11, 11, 5, 'Prodigal', '2.6.3', 'Protein-coding gene prediction for prokaryotes.', 'https://github.com/hyattpd/Prodigal', 'GPLv3'),
 (12, 12, 5, 'Glimmer', '3.02', 'Microbial gene identification.', 'http://ccb.jhu.edu/software/glimmer/', 'Artistic License'),

 -- Motif Discovery
 (13, 13, 11, 'MEME Suite', '5.5.5', 'Motif-based sequence analysis tools.', 'https://meme-suite.org/', 'Non-Commercial'),
 (14, 14, 12, 'HOMER', '4.11', 'Software for motif discovery and NGS analysis.', 'http://homer.ucsd.edu/homer/', 'GPLv3'),

 -- Phylogenetic Reconstruction
 (15, 16, 6, 'RAxML-NG', '1.2.1', 'Next-generation Maximum Likelihood tree inference.', 'https://github.com/amkozlov/raxml-ng', 'GPL'),
 (16, 17, 9, 'IQ-TREE 2', '2.3.1', 'Efficient phylogenomic software.', 'http://www.iqtree.org/', 'GPL'),
 (17, 18, NULL, 'MrBayes', '3.2.7', 'Bayesian inference of phylogeny.', 'http://mrbayes.sourceforge.net/', 'GPL'),

 -- Functional Annotation
 (18, 19, NULL, 'OmicsBox', '3.1', 'Bioinformatics platform including Blast2GO.', 'https://www.biobam.com/omicsbox/', 'Commercial'),
 (19, 20, 3, 'InterProScan', '5.66', 'Functional analysis of proteins.', 'https://github.com/ebi-pf-team/interproscan', 'Apache 2.0'),

 -- Secondary Structure
 (20, 22, 14, 'PSIPRED', '4.0', 'Protein secondary structure prediction.', 'http://bioinf.cs.ucl.ac.uk/psipred/', 'Academic Only'),
 (21, 23, 9, 'ViennaRNA', '2.6.4', 'RNA secondary structure prediction package.', 'https://www.tbi.univie.ac.at/RNA/', 'Non-Commercial'),
 (22, 24, 13, 'JPred4', '4.0', 'Secondary structure prediction server.', 'http://www.compbio.dundee.ac.uk/jpred/', 'Academic Only'),

 -- Tertiary Structure
 (23, 25, 2, 'AlphaFold', '2.3.2', 'AI system for protein structure prediction.', 'https://github.com/deepmind/alphafold', 'Apache 2.0'),
 (24, 26, 4, 'Rosetta', '3.13', 'Software suite for macromolecular modeling.', 'https://www.rosettacommons.org/', 'Academic/Commercial'),
 (25, 27, 10, 'I-TASSER Suite', '5.2', 'Protein structure and function prediction.', 'https://zhanggroup.org/I-TASSER/', 'Academic Only');

-- Re-enable foreign keys
SET FOREIGN_KEY_CHECKS = 1;