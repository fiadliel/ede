{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections     #-}

-- Module      : Text.EDE.Internal.AST
-- Copyright   : (c) 2013-2014 Brendan Hay <brendan.g.hay@gmail.com>
-- License     : This Source Code Form is subject to the terms of
--               the Mozilla Public License, v. 2.0.
--               A copy of the MPL can be found in the LICENSE file or
--               you can obtain it at http://mozilla.org/MPL/2.0/.
-- Maintainer  : Brendan Hay <brendan.g.hay@gmail.com>
-- Stability   : experimental
-- Portability : non-portable (GHC extensions)

-- | Abstract syntax smart constructors.
module Text.EDE.Internal.AST where

import Data.Foldable           (foldl', foldr')
import Data.List.NonEmpty      (NonEmpty(..))
import Data.Maybe
import Data.Monoid
import Data.Text               (Text)
import Text.EDE.Internal.Types
import Text.Trifecta.Delta

var :: Id -> Var
var = Var . (:| [])

-- evar :: Var -> Exp
-- evar v = EVar (meta v) v

eapp :: Exp -> [Exp] -> Exp
eapp e [] = e
eapp e es = foldl' (\x -> EApp (delta x) x) e es

efun :: Delta -> Text -> Exp -> Exp
efun d = EApp d . EFun d . Id

-- elet :: Id -> Exp -> Exp -> Exp
-- elet i = ELet (delta i) i

ecase :: Exp -> [Alt] -> Maybe Exp -> Exp
ecase p ws f = ECase (delta p) p (ws ++ maybe [] ((:[]) . wild) f)

eif :: (Exp, Exp) -> [(Exp, Exp)] -> Maybe Exp -> Exp
eif t@(x, _) ts f = foldr' c (fromMaybe (bld (delta x)) f) (t:ts)
  where
    c (p, w) e = ECase (delta p) p [true w, false e]

-- eloop :: Delta -> Id -> Var -> Exp -> Maybe Exp -> Exp
-- eloop d i = ELoop d i

wild, true, false :: Exp -> Alt
wild  = (PWild,)
true  = (PLit (LBool True),)
false = (PLit (LBool False),)

bld :: Delta -> Exp
bld = (`ELit` LText mempty)
