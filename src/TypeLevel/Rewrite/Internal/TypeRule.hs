{-# LANGUAGE ViewPatterns #-}
module TypeLevel.Rewrite.Internal.TypeRule where

-- GHC API
import Name (getOccString)
import TyCon (TyCon)
import Type (TyVar, Type)

-- term-rewriting API
import Data.Rewriting.Rule (Rule(..))
import Data.Rewriting.Rules (Reduct(result), fullRewrite)
import Data.Rewriting.Term (Term(Fun))

import TypeLevel.Rewrite.Internal.TypeTemplate
import TypeLevel.Rewrite.Internal.TypeTerm


type TypeRule = Rule TyCon TyVar

toTypeRule_maybe
  :: Type
  -> Maybe TypeRule
toTypeRule_maybe (toTypeTemplate_maybe -> Just (Fun (getOccString -> "~") [_type, lhs_, rhs_]))
  = Just (Rule lhs_ rhs_)
toTypeRule_maybe _
  = Nothing

applyRules
  :: [TypeRule]
  -> TypeTerm
  -> TypeTerm
applyRules rules
  = go (length rules * 100)
  where
    go :: Int -> TypeTerm -> TypeTerm
    go 0 _
      = error "the rewrite rules form a cycle"
    go fuel typeTerm
      = case fullRewrite rules typeTerm of
          []
            -> typeTerm
          reducts
            -> go (fuel - 1) . result . last $ reducts
